import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/core/network/api_routes.dart';
import '../../data/model/my_product_model.dart';
import 'package:get/get.dart';
import '../../../buy_product/presentation/screens/product_detail_screen.dart';
import '../../../buy_product/presentation/bindings/buy_product_binding.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final List<MyProductModel> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF17181C), size: 20),
        ),
        title: const Text(
          'My Products',
          style: TextStyle(
            color: Color(0xFF17181C),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1400FF)),
            );
          }
          if (_errorMessage != null) {
            return _ErrorView(
              message: _errorMessage!,
              onRetry: _loadProducts,
            );
          }
          if (_products.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            color: const Color(0xFF1400FF),
            onRefresh: _loadProducts,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.sp),
              itemCount: _products.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.sp),
              itemBuilder: (_, index) => _ProductCard(product: _products[index]),
            ),
          );
        },
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
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFFDD3344);
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'approve':
      case 'approved':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFFFEBEB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = double.tryParse(product.discount) != null &&
        (double.tryParse(product.discount) ?? 0) > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(
            () => ProductDetailScreen(productId: product.id),
            binding: BuyProductBinding(),
          );
        },
        child: Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90.sp,
                  height: 90.sp,
                  child: Image.network(
                    product.metaImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFDEEAFF),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Color(0xFF1400FF),
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 14.sp),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category & Subcategory tags
                        Expanded(
                          child: Text(
                            '${product.categoryName} • ${product.subcategoryName}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF72757F),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Admin status
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
                          decoration: BoxDecoration(
                            color: _getStatusBg(product.adminStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.adminStatus.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(product.adminStatus),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.sp),

                    // Title
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17181C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.sp),

                    // Price information
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatCurrency(product.totalCost),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1400FF),
                          ),
                        ),
                        if (hasDiscount) ...[
                          SizedBox(width: 6.sp),
                          Text(
                            _formatCurrency(product.price),
                            style: TextStyle(
                              fontSize: 11.sp,
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFF8A8FA3),
                            ),
                          ),
                          SizedBox(width: 6.sp),
                          Text(
                            '${double.tryParse(product.discount)?.toInt()}% OFF',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 8.sp),

                    // Enquiry indicators
                    Row(
                      children: [
                        Icon(Icons.question_answer_outlined, size: 14.sp, color: const Color(0xFF8A8FA3)),
                        SizedBox(width: 4.sp),
                        Text(
                          'Enquiries: ${product.totalEnquiry}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF72757F),
                            fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (product.unreadEnquiry > 0) ...[
                      SizedBox(width: 10.sp),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDD3344),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${product.unreadEnquiry} NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
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
);
}
}

// ── Empty & Error Views ──────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFDEEAFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.storefront_outlined,
                color: Color(0xFF1400FF), size: 38),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Products Listed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF17181C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'List items you want to sell and\nthey will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF8A8FA3)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Color(0xFF8A8FA3), size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF72757F), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1400FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
