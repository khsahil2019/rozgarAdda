import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../chat/presentation/controller/chat_controller.dart';
import '../../../chat/presentation/bindings/chat_binding.dart';
import '../../domain/entities/buy_product_entities.dart';
import '../controller/buy_product_controller.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _DC {
  static const Color primary = Color(0xFF1400FF);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color strikePrice = Color(0xFF9A9A9A);
  static const Color saveBadgeBg = Color(0xFFDD0000);
  static const Color offBadgeBg = Color(0xFFDD0000);
  static const Color divider = Color(0xFFEEEFF5);
  static const Color greenCheck = Color(0xFF1E9E5E);
  static const Color priceGreen = Color(0xFF1E9E5E);
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final BuyProductController controller = Get.find<BuyProductController>();

  @override
  void initState() {
    super.initState();
    controller.fetchProductDetails(widget.productId);
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
        title: Obx(() => Text(
              controller.productDetail.value?.title ?? 'Product Details',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            )),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Obx(() => _buildBody()),
      bottomNavigationBar: Obx(() {
        final product = controller.productDetail.value;
        if (product == null || controller.isLoadingDetail.value) {
          return const SizedBox.shrink();
        }
        return _buildBottomBar(context, product);
      }),
    );
  }

  Widget _buildBottomBar(BuildContext context, BuyProduct product) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (!Get.isRegistered<ChatController>()) {
                    ChatBinding().dependencies();
                  }
                  Get.find<ChatController>().initiateChat(product.id);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  foregroundColor: const Color(0xFF4F46E5),
                ),
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                label: const Text(
                  'Chat with Seller',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Enquiry Sent',
                      'Your buy enquiry for "${product.title}" has been submitted to the seller!',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 3),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_bag_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Enquire Now',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoadingDetail.value) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
    }

    if (controller.detailError.value != null) {
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
                controller.detailError.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () =>
                    controller.fetchProductDetails(widget.productId),
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

    final product = controller.productDetail.value;
    if (product == null) return const SizedBox.shrink();

    final images = product.allImages;
    final currentImage =
        images.isNotEmpty && controller.selectedImageIndex.value < images.length
            ? images[controller.selectedImageIndex.value]
            : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image + info card ──────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main image
                _MainImage(imageUrl: currentImage),
                const SizedBox(height: 14),

                // Thumbnails row
                if (images.length > 1)
                  _ThumbnailRow(
                    images: images,
                    selectedIndex: controller.selectedImageIndex.value,
                    onTap: controller.selectImage,
                  ),

                const SizedBox(height: 20),

                // Title
                Text(
                  product.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),

                // Price row
                _PriceRow(
                  discountedPrice: product.totalCost,
                  originalPrice: product.price,
                  discount: product.discount,
                ),
                const SizedBox(height: 20),

                // Description
                const _SectionTitle(title: 'Product Overview & Description'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                  ),
                  child: Text(
                    product.description.isNotEmpty ? product.description : 'High quality product available directly from verified seller.',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13.5,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Specs row
                _SpecsRow(
                  warranty: product.warranty,
                  capacity: product.capacity,
                ),
                const SizedBox(height: 20),

                // Key Features
                if (product.featureList.isNotEmpty) ...[
                  const _SectionTitle(title: 'Key Features & Specifications'),
                  const SizedBox(height: 10),
                  ...product.featureList.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF059669),
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                f,
                                style: const TextStyle(
                                  color: Color(0xFF047857),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),

          // ── Related Products ────────────────────────
          if (controller.relatedProducts.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'Related Products',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _RelatedProductsGrid(
              products: controller.relatedProducts,
              onProductTap: (id) {
                Get.off(() => ProductDetailScreen(productId: id),
                    preventDuplicates: false);
              },
            ),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN IMAGE
// ─────────────────────────────────────────────
class _MainImage extends StatelessWidget {
  final String? imageUrl;
  const _MainImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0EE)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.directions_car_filled_rounded,
        size: 64,
        color: Color(0xFFBBBBDD),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// THUMBNAIL ROW
// ─────────────────────────────────────────────
class _ThumbnailRow extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _ThumbnailRow({
    required this.images,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(images.length, (i) {
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 72,
              height: 58,
              margin: EdgeInsets.only(right: i < images.length - 1 ? 10 : 0),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _DC.primary : const Color(0xFFDDDDEE),
                  width: isSelected ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_outlined,
                  size: 24,
                  color: Color(0xFFBBBBCC),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRICE ROW
// ─────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final double discountedPrice;
  final double originalPrice;
  final double discount;

  const _PriceRow({
    required this.discountedPrice,
    required this.originalPrice,
    required this.discount,
  });

  String _fmt(double price) {
    return '₹${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        Text(
          _fmt(discountedPrice),
          style: const TextStyle(
            color: _DC.darkText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (discount > 0) ...[
          Text(
            _fmt(originalPrice),
            style: const TextStyle(
              color: _DC.strikePrice,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _DC.saveBadgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Save ${discount.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SPECS ROW (warranty + capacity)
// ─────────────────────────────────────────────
class _SpecsRow extends StatelessWidget {
  final String warranty;
  final String capacity;

  const _SpecsRow({required this.warranty, required this.capacity});

  @override
  Widget build(BuildContext context) {
    final List<_SpecItem> specs = [
      if (warranty.isNotEmpty)
        _SpecItem(
          icon: Icons.verified_rounded,
          label: 'Warranty',
          value: warranty,
        ),
      if (capacity.isNotEmpty)
        _SpecItem(
          icon: Icons.people_rounded,
          label: 'Capacity',
          value: capacity,
        ),
    ];

    if (specs.isEmpty) return const SizedBox.shrink();

    return Row(
      children: specs
          .map(
            (s) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDDDFFF)),
                ),
                child: Row(
                  children: [
                    Icon(s.icon, size: 18, color: _DC.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.label,
                            style: const TextStyle(
                              color: _DC.greyText,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            s.value,
                            style: const TextStyle(
                              color: _DC.darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;
  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

// ─────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _DC.darkText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RELATED PRODUCTS GRID
// ─────────────────────────────────────────────
class _RelatedProductsGrid extends StatelessWidget {
  final List<BuyProduct> products;
  final ValueChanged<int> onProductTap;

  const _RelatedProductsGrid({
    required this.products,
    required this.onProductTap,
  });

  String _fmt(double price) {
    return '₹${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, i) {
        final p = products[i];
        return GestureDetector(
          onTap: () => onProductTap(p.id),
          child: Container(
            decoration: BoxDecoration(
              color: _DC.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with OFF badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: const Color(0xFFEEEFF8),
                        child: p.metaImage.isNotEmpty
                            ? Image.network(
                                p.metaImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.directions_car_filled_rounded,
                                  size: 48,
                                  color: Color(0xFFBBBBDD),
                                ),
                              )
                            : const Icon(
                                Icons.directions_car_filled_rounded,
                                size: 48,
                                color: Color(0xFFBBBBDD),
                              ),
                      ),
                    ),
                    if (p.discount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _DC.offBadgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${p.discount.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _DC.darkText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _DC.greyText,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (p.discount > 0)
                          Text(
                            _fmt(p.price),
                            style: const TextStyle(
                              color: _DC.strikePrice,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmt(p.totalCost),
                              style: const TextStyle(
                                color: _DC.priceGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              'View',
                              style: TextStyle(
                                color: _DC.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
