import '../../domain/entities/buy_product_entities.dart';

class BuyProductCategoryModel extends BuyProductCategory {
  const BuyProductCategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
  });

  factory BuyProductCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    return BuyProductCategoryModel(
      id: parsedId,
      name: json['name']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': imageUrl,
    };
  }
}

class BuyProductSubCategoryModel extends BuyProductSubCategory {
  const BuyProductSubCategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
  });

  factory BuyProductSubCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    return BuyProductSubCategoryModel(
      id: parsedId,
      name: json['name']?.toString() ?? '',
      imageUrl: (json['image_url'] ?? json['image'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
    };
  }
}

class BuyProductModel extends BuyProduct {
  const BuyProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.metaImage,
    required super.galleryImages,
    required super.price,
    required super.discount,
    required super.totalCost,
    required super.features,
    required super.warranty,
    required super.capacity,
  });

  factory BuyProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    final rawGallery = json['gallery_images'];
    final List<String> gallery = rawGallery is List
        ? rawGallery
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList()
        : [];

    return BuyProductModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      metaImage: (json['meta_image'] ?? '').toString(),
      galleryImages: gallery,
      price: parseDouble(json['price']),
      discount: parseDouble(json['discount']),
      totalCost: parseDouble(json['total_cost']),
      features: (json['features'] ?? '').toString(),
      warranty: (json['warranty'] ?? '').toString(),
      capacity: (json['capacity'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'meta_image': metaImage,
      'gallery_images': galleryImages,
      'price': price,
      'discount': discount,
      'total_cost': totalCost,
      'features': features,
      'warranty': warranty,
      'capacity': capacity,
    };
  }
}
