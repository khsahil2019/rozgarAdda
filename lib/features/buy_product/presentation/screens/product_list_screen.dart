import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/buy_product_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import 'product_detail_screen.dart';
import '../../../../core/widgets/fast_loader.dart';


// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class ProductListScreen extends StatefulWidget {
  final String? title;
  final int? categoryId;
  final int? subcategoryId;

  const ProductListScreen({
    super.key,
    this.title,
    this.categoryId,
    this.subcategoryId,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final BuyProductController controller = Get.find<BuyProductController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize filter state and fetch products + subcategories
      controller.selectedSubCategoryId.value = widget.subcategoryId;
      controller.fetchProducts(widget.categoryId, widget.subcategoryId);
      if (widget.categoryId != null) {
        controller.fetchSubCategories(widget.categoryId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 58,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 7, bottom: 7),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A),
                  size: 17,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title ?? 'Buy Products',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Obx(() => Text(
                  '${controller.products.length} Products Available',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                )),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Decorative Search bar on top
          _buildSearchBar(),

          // 🎛️ Subcategory Filter Chips
          if (widget.categoryId != null) _buildFilterChips(),

          // 📦 Main Feed
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Search in ${widget.title ?? "Products"}...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4F46E5), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      if (controller.isLoadingSubCategories.value && controller.subCategories.isEmpty) {
        return const SizedBox(
          height: 50,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
            ),
          ),
        );
      }

      if (controller.subCategories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        color: Colors.white,
        height: 48,
        padding: const EdgeInsets.only(bottom: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.subCategories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final isSelected = isAll
                ? controller.selectedSubCategoryId.value == null
                : controller.selectedSubCategoryId.value ==
                    controller.subCategories[index - 1].id;

            final label = isAll ? 'All' : controller.subCategories[index - 1].name;
            final subId = isAll ? null : controller.subCategories[index - 1].id;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF334155),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
                selectedColor: const Color(0xFFEEF2FF),
                backgroundColor: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                onSelected: (selected) {
                  if (selected) {
                    controller.selectSubCategoryFilter(widget.categoryId, subId);
                  }
                },
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoadingProducts.value) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: FastGridSkeleton(itemCount: 6),
        );
      }

      if (controller.productsError.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 52,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.productsError.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchProducts(
                    widget.categoryId,
                    controller.selectedSubCategoryId.value,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.products.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 52, color: Color(0xFF94A3B8)),
                SizedBox(height: 12),
                Text(
                  'No products available in this category.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchProducts(
          widget.categoryId,
          controller.selectedSubCategoryId.value,
        ),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          itemCount: controller.products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, i) =>
              _ProductCard(product: controller.products[i]),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// PRODUCT CARD (High-end Marketplace Style)
// ─────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final BuyProduct product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isLiked = false;

  String _formatPrice(double price) {
    return '₹${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  void _openDetail(BuildContext context) {
    Get.to(() => ProductDetailScreen(productId: widget.product.id));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasDiscount = product.discount > 0;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(17),
                      ),
                      child: product.metaImage.isNotEmpty
                          ? Image.network(
                              product.metaImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _PlaceholderImage(),
                            )
                          : _PlaceholderImage(),
                    ),
                  ),
                  // FEATURED Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCD34D), width: 1),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  // Heart Icon (Favorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isLiked = !_isLiked);
                        Get.snackbar(
                          _isLiked ? 'Saved to Favorites' : 'Removed from Favorites',
                          _isLiked ? '${product.title} saved to wishlist' : 'Removed from wishlist',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isLiked ? const Color(0xFFEF4444) : const Color(0xFF475569),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price row with discount badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatPrice(product.totalCost),
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasDiscount)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                          ),
                          child: Text(
                            '${product.discount.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Description snippet
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 6),

                  // Location Footer
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFEF4444),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Verified Seller',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PLACEHOLDER IMAGE
// ─────────────────────────────────────────────
class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEEFF5),
      child: const Icon(
        Icons.image_outlined,
        size: 36,
        color: Color(0xFFBBBBCC),
      ),
    );
  }
}
