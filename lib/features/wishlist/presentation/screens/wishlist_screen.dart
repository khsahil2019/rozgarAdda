import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../../../../core/widgets/network_image_service.dart';
import '../../../buy_product/domain/entities/buy_product_entities.dart';
import '../../../buy_product/presentation/screens/product_category_list_screen.dart';
import '../../../buy_product/presentation/screens/product_detail_screen.dart';
import '../controller/wishlist_controller.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController controller = WishlistController.to;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    controller.fetchWishlist(silent: true);
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 8),
            Text(
              'Clear Wishlist?',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to remove all saved items from your wishlist?',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.clearAll();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
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
            const Text(
              'My Wishlist',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 1),
            Obx(() => Text(
                  '${controller.itemCount} ${controller.itemCount == 1 ? "Item" : "Items"} Saved',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                )),
          ],
        ),
        actions: [
          Obx(() {
            if (controller.itemCount == 0) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Clear All',
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              onPressed: () => _showClearAllDialog(context),
            );
          }),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.wishlistItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1400FF)),
          );
        }

        if (controller.wishlistItems.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          color: const Color(0xFF1400FF),
          onRefresh: () => controller.fetchWishlist(),
          child: Column(
            children: [
              // ── Sub-header: Toolbar & View toggle ─────
              _buildToolbar(),

              // ── Products List/Grid ────────────────────
              Expanded(
                child: _isGridView ? _buildGridView() : _buildListView(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFEF4444),
                size: 16,
              ),
              const SizedBox(width: 6),
              Obx(() => Text(
                    '${controller.itemCount} Products in your wishlist',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  )),
            ],
          ),
          // Grid / List Toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isGridView = true),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _isGridView ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: _isGridView
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: _isGridView
                          ? const Color(0xFF1400FF)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isGridView = false),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: !_isGridView ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: !_isGridView
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.view_list_rounded,
                      size: 16,
                      color: !_isGridView
                          ? const Color(0xFF1400FF)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 268,
      ),
      itemCount: controller.wishlistItems.length,
      itemBuilder: (context, index) {
        final item = controller.wishlistItems[index];
        final product = item.product;
        return _buildGridCard(product);
      },
    );
  }

  Widget _buildGridCard(BuyProduct product) {
    final hasDiscount = product.discount > 0;
    final fullImageUrl = ApiRoutes.absoluteUrl(product.metaImage);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id),
              ),
            ).then((_) => controller.fetchWishlist(silent: true));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image with Heart & Badge ─────────────────
              SizedBox(
                height: 135,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: NetworkImageService(
                          imageUrl: fullImageUrl,
                          width: double.infinity,
                          height: 135,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFF94A3B8),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Discount pill
                    if (hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '₹${product.discount.toStringAsFixed(0)} OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    // Delete / Heart button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => controller.removeFromWishlist(
                          product.id,
                          productTitle: product.title,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFFEF4444),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Card Details ────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Text(
                        product.title.isNotEmpty ? product.title : 'Product',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          height: 1.25,
                        ),
                      ),

                      // Price & Action row
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹${product.totalCost > 0 ? product.totalCost.toStringAsFixed(0) : product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF1400FF),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                ),
                              ),
                              if (hasDiscount && product.price > 0) ...[
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '₹${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Color(0xFF94A3B8),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          // View Details chip
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Color(0xFF1400FF),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10.5,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 9,
                                  color: Color(0xFF1400FF),
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      itemCount: controller.wishlistItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = controller.wishlistItems[index];
        final product = item.product;
        final fullImageUrl = ApiRoutes.absoluteUrl(product.metaImage);
        final hasDiscount = product.discount > 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                ).then((_) => controller.fetchWishlist(silent: true));
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: NetworkImageService(
                        imageUrl: fullImageUrl,
                        width: 86,
                        height: 86,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 86,
                          height: 86,
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Color(0xFF94A3B8),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Container(
                              margin: const EdgeInsets.only(bottom: 3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '₹${product.discount.toStringAsFixed(0)} SAVINGS',
                                style: const TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          Text(
                            product.title.isNotEmpty ? product.title : 'Product',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹${product.totalCost > 0 ? product.totalCost.toStringAsFixed(0) : product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF1400FF),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              if (hasDiscount && product.price > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '₹${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Remove Action
                    IconButton(
                      tooltip: 'Remove from wishlist',
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFEF4444),
                          size: 17,
                        ),
                      ),
                      onPressed: () => controller.removeFromWishlist(
                        product.id,
                        productTitle: product.title,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Layered Icon Badge
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1400FF).withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 46,
                  color: Color(0xFFEF4444),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Your Wishlist is Empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Explore products in our marketplace and save your favorites to easily view and buy them later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),

            // Explore Products Button
            SizedBox(
              width: 200,
              child: AppGradientButton(
                text: 'Explore Products',
                icon: Icons.storefront_rounded,
                height: 48,
                borderRadius: 14,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductCategoryListScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

