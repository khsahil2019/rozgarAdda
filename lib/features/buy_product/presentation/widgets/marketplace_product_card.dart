import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/widgets/network_image_service.dart';
import '../../../wishlist/presentation/controller/wishlist_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import '../screens/product_detail_screen.dart';
import '../theme/buy_product_theme.dart';

/// Shared 3-column marketplace product card featuring a bold reddish-maroon
/// border on all four sides (`foregroundDecoration`), discount badge, and wishlist button.
class MarketplaceProductCard extends StatelessWidget {
  final BuyProduct product;
  final bool showWishlistButton;
  final VoidCallback? onTap;

  const MarketplaceProductCard({
    super.key,
    required this.product,
    this.showWishlistButton = true,
    this.onTap,
  });

  static String formatPrice(double price) {
    if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(1)}L';
    }
    return '₹${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount > 0;
    final hasWishlistCtrl =
        showWishlistButton && Get.isRegistered<WishlistController>();

    return GestureDetector(
      onTap: onTap ??
          () => Get.to(
                () => ProductDetailScreen(
                  productId: product.id,
                  initialProduct: product,
                ),
              ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: BuyProductTheme.primaryMaroon.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        // Drawn cleanly on top so product images never overlap the card border.
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BuyProductTheme.borderMaroon,
            width: 2.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: BuyProductTheme.lightMaroonBg,
                      child: product.metaImage.isNotEmpty
                          ? NetworkImageService(
                              imageUrl: ApiRoutes.absoluteUrl(product.metaImage),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: const _ProductPlaceholderImage(),
                            )
                          : const _ProductPlaceholderImage(),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${product.discount.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  if (hasWishlistCtrl)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Obx(() {
                        final isLiked =
                            WishlistController.to.isWishlisted(product.id);
                        return GestureDetector(
                          onTap: () =>
                              WishlistController.to.toggleWishlist(product),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.16),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isLiked
                                  ? const Color(0xFFEF4444)
                                  : BuyProductTheme.primaryMaroon,
                              size: 13,
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatPrice(product.totalCost),
                    style: const TextStyle(
                      color: BuyProductTheme.primaryMaroon,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BuyProductTheme.darkText,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        color: BuyProductTheme.primaryMaroon,
                        size: 10,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          product.warranty.isNotEmpty
                              ? product.warranty
                              : (product.capacity.isNotEmpty
                                  ? product.capacity
                                  : 'Verified'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: BuyProductTheme.greyText,
                            fontSize: 9,
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

class _ProductPlaceholderImage extends StatelessWidget {
  const _ProductPlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BuyProductTheme.lightMaroonBg,
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: BuyProductTheme.primaryMaroon.withValues(alpha: 0.35),
          size: 26,
        ),
      ),
    );
  }
}

