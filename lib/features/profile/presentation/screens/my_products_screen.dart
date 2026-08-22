import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import '../../../buy_product/presentation/bindings/buy_product_binding.dart';
import '../../../buy_product/presentation/screens/product_detail_screen.dart';
import '../../../sell_product/presentation/screens/sell_product_category_screen.dart';
import '../../data/model/my_product_model.dart';

// Unified Rozgar Brand Color Tokens
class _PC {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
}

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final List<MyProductModel> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  final RxString _selectedFilter = 'all'.obs;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.post(ApiRoutes.myProducts);
      if (response['success'] == true) {
        final rawList = response['data'] as List<dynamic>? ?? [];
        _products.clear();
        for (var item in rawList) {
          _products.add(MyProductModel.fromJson(item as Map<String, dynamic>));
        }
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch products';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<MyProductModel> _getFilteredProducts() {
    final filter = _selectedFilter.value.toLowerCase();
    if (filter == 'all') return _products;
    if (filter == 'approved') {
      return _products.where((p) => p.adminStatus.toLowerCase() == 'approved' || p.adminStatus.toLowerCase() == 'approve').toList();
    }
    if (filter == 'pending') {
      return _products.where((p) => p.adminStatus.toLowerCase() == 'pending').toList();
    }
    if (filter == 'rejected') {
      return _products.where((p) => p.adminStatus.toLowerCase() == 'rejected' || p.adminStatus.toLowerCase() == 'reject').toList();
    }
    return _products;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredProducts();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _PC.bg,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _PC.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () => Get.to(() => const SellProductCategoryScreen()),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Sell Product',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Listed Products',
                style: TextStyle(
                  color: _PC.darkText,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                _products.isEmpty ? 'Manage marketplace listings' : '${_products.length} Items Listed',
                style: const TextStyle(
                  color: _PC.greyText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _PC.borderGrey),
          ),
        ),
        body: Builder(
          builder: (context) {
            if (_isLoading) {
              return _buildLoadingSkeleton();
            }
            if (_errorMessage != null) {
              return _buildErrorView(_errorMessage!);
            }
            if (_products.isEmpty) {
              return const _EmptyView();
            }

            return Column(
              children: [
                // Filter Segment Bar
                _buildFilterBar(),

                // Products List
                Expanded(
                  child: RefreshIndicator(
                    color: _PC.primary,
                    onRefresh: _loadProducts,
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _PC.primary.withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.filter_list_off_rounded,
                                      size: 40,
                                      color: _PC.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No products in this category',
                                    style: TextStyle(
                                      color: _PC.darkText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (_, index) => _ProductCard(product: filtered[index]),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    int approvedCount = 0;
    int pendingCount = 0;
    int rejectedCount = 0;

    for (var p in _products) {
      final s = p.adminStatus.toLowerCase();
      if (s == 'approved' || s == 'approve') {
        approvedCount++;
      } else if (s == 'pending') {
        pendingCount++;
      } else if (s == 'rejected' || s == 'reject') {
        rejectedCount++;
      }
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterPill('all', 'All (${_products.length})'),
            const SizedBox(width: 8),
            _buildFilterPill('approved', 'Approved ($approvedCount)'),
            const SizedBox(width: 8),
            _buildFilterPill('pending', 'Pending ($pendingCount)'),
            const SizedBox(width: 8),
            _buildFilterPill('rejected', 'Rejected ($rejectedCount)'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String filterKey, String label) {
    return Obx(() {
      final active = _selectedFilter.value == filterKey;
      return InkWell(
        onTap: () => _selectedFilter.value = filterKey,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? _PC.primary : _PC.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? _PC.primary : _PC.borderGrey,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _PC.mediumText,
              fontSize: 12,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (ctx, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _PC.borderGrey),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 12, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Container(width: double.infinity, height: 15, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 14, color: Colors.grey.shade200),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _PC.dangerRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, color: _PC.dangerRed, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Products',
              style: TextStyle(
                color: _PC.darkText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _PC.greyText, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _PC.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final MyProductModel product;
  const _ProductCard({required this.product});

  String _formatCurrency(String value) {
    final raw = double.tryParse(value) ?? 0;
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return '₹${formatter.format(raw.toInt())}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approve':
      case 'approved':
        return _PC.successGreen;
      case 'pending':
        return _PC.warningOrange;
      default:
        return _PC.dangerRed;
    }
  }

  Color _getStatusBg(String status) {
    return _getStatusColor(status).withValues(alpha: 0.08);
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = double.tryParse(product.discount) != null &&
        (double.tryParse(product.discount) ?? 0) > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _PC.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Get.to(
              () => ProductDetailScreen(productId: product.id),
              binding: BuyProductBinding(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: Image.network(
                      product.metaImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _PC.primary.withValues(alpha: 0.08),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: _PC.primary,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category Tag
                          Expanded(
                            child: Text(
                              '${product.categoryName} • ${product.subcategoryName}'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: _PC.primary,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusBg(product.adminStatus),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(product.adminStatus).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              product.adminStatus.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(product.adminStatus),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Title
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: _PC.darkText,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Price information
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatCurrency(product.totalCost),
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: _PC.primary,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text(
                              _formatCurrency(product.price),
                              style: const TextStyle(
                                fontSize: 11.5,
                                decoration: TextDecoration.lineThrough,
                                color: _PC.greyText,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${double.tryParse(product.discount)?.toInt()}% OFF',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: _PC.successGreen,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Enquiry indicators
                      Row(
                        children: [
                          const Icon(Icons.question_answer_outlined, size: 13, color: _PC.greyText),
                          const SizedBox(width: 4),
                          Text(
                            'Enquiries: ${product.totalEnquiry}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _PC.greyText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (product.unreadEnquiry > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _PC.dangerRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${product.unreadEnquiry} NEW',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _PC.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: _PC.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Products Listed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _PC.darkText,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'List items and equipment you want to sell\nand they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: _PC.greyText, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const SellProductCategoryScreen()),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Sell Your First Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _PC.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
