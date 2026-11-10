class SellProductCategory {
  final int id;
  final String name;
  final String imageUrl;

  const SellProductCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class SellProductSubCategory {
  final int id;
  final String name;
  final String imageUrl;

  const SellProductSubCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class SellProductRequest {
  final int categoryId;
  final int subCategoryId;
  final String title;
  final String description;
  final double price;
  final int discount;
  final String features;
  final String capacity;
  final String warranty;
  final bool isActive;
  final String mainImagePath;
  final List<String> galleryImagePaths;
  final int? planId;
  final String? transactionId;
  final String? paymentId;
  final String? paymentStatus;
  final Map<String, dynamic>? paymentData;

  const SellProductRequest({
    required this.categoryId,
    required this.subCategoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.discount,
    required this.features,
    required this.capacity,
    required this.warranty,
    required this.isActive,
    required this.mainImagePath,
    required this.galleryImagePaths,
    this.planId,
    this.transactionId,
    this.paymentId,
    this.paymentStatus,
    this.paymentData,
  });
}
