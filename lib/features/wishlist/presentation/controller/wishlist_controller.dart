import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../buy_product/domain/entities/buy_product_entities.dart';
import '../../data/model/wishlist_model.dart';
import '../../domain/repository/wishlist_repository.dart';

class WishlistController extends GetxController {
  final WishlistRepository repository;

  WishlistController({required this.repository});

  static WishlistController get to => Get.find<WishlistController>();

  final RxList<WishlistItemModel> wishlistItems = <WishlistItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  /// Check whether a product is currently in the wishlist
  bool isWishlisted(int productId) {
    return wishlistItems.any((item) => item.productId == productId);
  }

  /// Get wishlist count
  int get itemCount => wishlistItems.length;

  /// Fetch wishlist from API / cache
  Future<void> fetchWishlist({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = null;

    final result = await repository.getWishlist();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
      },
      (data) {
        wishlistItems.assignAll(data);
      },
    );

    if (!silent) isLoading.value = false;
  }

  /// Toggle item in wishlist with immediate optimistic UI update
  Future<bool> toggleWishlist(BuyProduct product, {bool showToast = true}) async {
    final alreadyIn = isWishlisted(product.id);

    // Optimistic UI update
    if (alreadyIn) {
      wishlistItems.removeWhere((item) => item.productId == product.id);
    } else {
      wishlistItems.insert(0, WishlistItemModel.fromProduct(product));
    }

    if (showToast) {
      Get.rawSnackbar(
        messageText: Row(
          children: [
            Icon(
              alreadyIn ? Icons.favorite_border_rounded : Icons.favorite_rounded,
              color: alreadyIn ? Colors.white70 : const Color(0xFFEF4444),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                alreadyIn
                    ? '${product.title} removed from wishlist'
                    : '${product.title} saved to wishlist',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }

    // Backend sync
    final result = await repository.toggleWishlist(product);
    return result.fold(
      (failure) {
        // In case of error, revert optimistic state
        if (alreadyIn) {
          wishlistItems.insert(0, WishlistItemModel.fromProduct(product));
        } else {
          wishlistItems.removeWhere((item) => item.productId == product.id);
        }
        return alreadyIn;
      },
      (nowIn) => nowIn,
    );
  }

  /// Remove item from wishlist
  Future<void> removeFromWishlist(int productId, {String? productTitle}) async {
    final existingIndex =
        wishlistItems.indexWhere((item) => item.productId == productId);
    if (existingIndex < 0) return;

    final removedItem = wishlistItems.removeAt(existingIndex);

    Get.rawSnackbar(
      messageText: Row(
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              productTitle != null
                  ? '$productTitle removed'
                  : 'Product removed from wishlist',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E293B),
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    final result = await repository.removeFromWishlist(productId);
    result.fold(
      (failure) {
        // restore if failure
        wishlistItems.insert(existingIndex, removedItem);
      },
      (_) {},
    );
  }

  /// Clear all items
  Future<void> clearAll() async {
    final backup = List<WishlistItemModel>.from(wishlistItems);
    wishlistItems.clear();

    final result = await repository.clearWishlist();
    result.fold(
      (failure) {
        wishlistItems.assignAll(backup);
      },
      (_) {},
    );
  }
}

