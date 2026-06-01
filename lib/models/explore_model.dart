import 'dart:convert';

class DashboardCategory {
  final int id;
  final String name;
  final String image; // image file name from API
  final String? imageUrlOverride;

  const DashboardCategory({
    required this.id,
    required this.name,
    required this.image,
    this.imageUrlOverride,
  });

  String get imageUrl {
    if (imageUrlOverride != null && imageUrlOverride!.isNotEmpty) {
      return imageUrlOverride!;
    }
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    // Adjust base path here if backend changes
    return 'https://rozgaradda.com/assets/images/$image';
  }

  factory DashboardCategory.fromJson(Map<String, dynamic> json) {
    return DashboardCategory(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      imageUrlOverride: json['image_url']?.toString(),
    );
  }

  static List<DashboardCategory> listFromResponseBody(String body) {
    final decoded = json.decode(body) as Map<String, dynamic>;
    final data = decoded['data'];
    final list = data is List<dynamic>
        ? data
        : (data as Map<String, dynamic>?)?['categories'] as List<dynamic>? ??
              <dynamic>[];

    return list
        .map((e) => DashboardCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class DashboardSubCategory {
  final int id;
  final String name;
  final String image;
  final String imageUrl;

  const DashboardSubCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.imageUrl,
  });

  factory DashboardSubCategory.fromJson(Map<String, dynamic> json) {
    final image = (json['image'] ?? '').toString();
    final imageUrl = (json['image_url'] ?? '').toString();
    return DashboardSubCategory(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      image: image,
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://rozgaradda.com/categories/$image',
    );
  }
}
