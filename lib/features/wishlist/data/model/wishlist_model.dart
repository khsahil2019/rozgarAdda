import '../../../buy_product/data/model/buy_product_dtos.dart';
import '../../../buy_product/domain/entities/buy_product_entities.dart';

class WishlistItemModel {
  final int wishlistId;
  final int productId;
  final DateTime? addedAt;
  final BuyProduct product;

  WishlistItemModel({
    required this.wishlistId,
    required this.productId,
    this.addedAt,
    required this.product,
  });

  factory WishlistItemModel.fromProduct(BuyProduct product) {
    return WishlistItemModel(
      wishlistId: product.id,
      productId: product.id,
      addedAt: DateTime.now(),
      product: product,
    );
  }

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? productMap;
    if (json['product'] is Map<String, dynamic>) {
      productMap = json['product'] as Map<String, dynamic>;
    } else if (json['product_details'] is Map<String, dynamic>) {
      productMap = json['product_details'] as Map<String, dynamic>;
    } else if (json['item'] is Map<String, dynamic>) {
      productMap = json['item'] as Map<String, dynamic>;
    }

    if (productMap != null) {
      final product = BuyProductModel.fromJson(productMap);
      final rawWishlistId = json['id'] ?? json['wishlist_id'];
      final rawProductId = json['product_id'] ?? productMap['id'] ?? product.id;
      return WishlistItemModel(
        wishlistId: rawWishlistId is int
            ? rawWishlistId
            : int.tryParse(rawWishlistId?.toString() ?? '') ?? product.id,
        productId: rawProductId is int
            ? rawProductId
            : int.tryParse(rawProductId?.toString() ?? '') ?? product.id,
        addedAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        product: product,
      );
    }

    final product = BuyProductModel.fromJson(json);
    final rawWishlistId = json['wishlist_id'] ?? json['id'];
    return WishlistItemModel(
      wishlistId: rawWishlistId is int
          ? rawWishlistId
          : int.tryParse(rawWishlistId?.toString() ?? '') ?? product.id,
      productId: product.id,
      addedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      product: product,
    );
  }

  Map<String, dynamic> toJson() {
    final productMap = product is BuyProductModel
        ? (product as BuyProductModel).toJson()
        : {
            'id': product.id,
            'title': product.title,
            'description': product.description,
            'meta_image': product.metaImage,
            'gallery_images': product.galleryImages,
            'price': product.price,
            'discount': product.discount,
            'total_cost': product.totalCost,
            'features': product.features,
            'warranty': product.warranty,
            'capacity': product.capacity,
          };

    return {
      'wishlist_id': wishlistId,
      'product_id': productId,
      'created_at': addedAt?.toIso8601String(),
      'product': productMap,
    };
  }
}

