import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/buy_product_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import 'product_detail_screen.dart';
import '../../../../core/widgets/fast_loader.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const Color primary = Color(0xFF1400FF);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color priceGreen = Color(0xFF1E9E5E);
  static const Color discountRed = Color(0xFFDD0000);
}

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
      backgroundColor: _C.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _C.darkText,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.title ?? 'Products',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: _C.scaffoldBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Search in ${widget.title ?? "Products"}',
            hintStyle: const TextStyle(color: _C.greyText, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: _C.greyText, size: 20),
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
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (controller.subCategories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        color: Colors.white,
        height: 50,
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
                  color: isSelected ? Colors.white : _C.darkText,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                selectedColor: _C.primary,
                backgroundColor: _C.scaffoldBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? _C.primary : const Color(0xFFECEEF5),
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
                  color: _C.greyText,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.productsError.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _C.greyText, fontSize: 15),
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
                    backgroundColor: _C.primary,
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
                Icon(Icons.inbox_rounded, size: 52, color: _C.greyText),
                SizedBox(height: 12),
                Text(
                  'No products available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _C.greyText, fontSize: 15),
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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          itemCount: controller.products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.70,
          ),
          itemBuilder: (context, i) =>
              _ProductCard(product: controller.products[i]),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// PRODUCT CARD (OLX Style)
// ─────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final BuyProduct product;
  const _ProductCard({required this.product});

  String _formatPrice(double price) {
    return '₹${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  void _openDetail(BuildContext context) {
    Get.to(() => ProductDetailScreen(productId: product.id));
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount > 0;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFECEEF5),
            width: 1,
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
                        top: Radius.circular(11),
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
                  // FEATURED Badge (Like OLX screenshot)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCE00),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: _C.darkText,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  // Heart Icon (Favorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: _C.darkText,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price row with discount
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatPrice(product.totalCost),
                          style: const TextStyle(
                            color: _C.darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (hasDiscount)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: _C.discountRed.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.discount.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color: _C.discountRed,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
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
                      color: Color(0xFF4B5563),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description snippet
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.greyText,
                      fontSize: 11,
                    ),
                  ),
                  const Divider(color: Color(0xFFECEEF5), height: 16, thickness: 1),

                  // Location (OLX Style footer)
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: _C.greyText,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Chak Bhikhari, Ghazipur',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _C.greyText,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
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
