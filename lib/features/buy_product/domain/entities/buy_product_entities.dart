class BuyProductCategory {
  final int id;
  final String name;
  final String imageUrl;

  const BuyProductCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class BuyProductSubCategory {
  final int id;
  final String name;
  final String imageUrl;

  const BuyProductSubCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class BuyProduct {
  final int id;
  final String title;
  final String description;
  final String metaImage;
  final List<String> galleryImages;
  final double price;
  final double discount;
  final double totalCost;
  final String features;
  final String warranty;
  final String capacity;

  const BuyProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.metaImage,
    required this.galleryImages,
    required this.price,
    required this.discount,
    required this.totalCost,
    required this.features,
    required this.warranty,
    required this.capacity,
  });

  List<String> get allImages => [
        if (metaImage.isNotEmpty) metaImage,
        ...galleryImages,
      ];

  List<String> get featureList {
    final list = features
        .split(',')
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();
    return list.isEmpty && features.isNotEmpty ? [features] : list;
  }
}

class BuyProductDetailResponse {
  final BuyProduct product;
  final List<BuyProduct> relatedProducts;

  const BuyProductDetailResponse({
    required this.product,
    required this.relatedProducts,
  });
}
