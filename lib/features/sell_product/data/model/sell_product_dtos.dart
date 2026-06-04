import '../../domain/entities/sell_product_entities.dart';

class SellProductCategoryModel extends SellProductCategory {
  const SellProductCategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
  });

  factory SellProductCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    return SellProductCategoryModel(
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

class SellProductSubCategoryModel extends SellProductSubCategory {
  const SellProductSubCategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
  });

  factory SellProductSubCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    return SellProductSubCategoryModel(
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
