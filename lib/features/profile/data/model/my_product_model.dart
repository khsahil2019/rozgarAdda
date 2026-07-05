class MyProductModel {
  final int id;
  final String title;
  final String slug;
  final int categoryId;
  final int subcategoryId;
  final String description;
  final String metaImage;
  final List<String> galleryImages;
  final String price;
  final String discount;
  final String totalCost;
  final String features;
  final String capacity;
  final String warranty;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int addedBy;
  final String adminStatus;
  final String categoryName;
  final String subcategoryName;
  final int totalEnquiry;
  final int unreadEnquiry;

  MyProductModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.categoryId,
    required this.subcategoryId,
    required this.description,
    required this.metaImage,
    required this.galleryImages,
    required this.price,
    required this.discount,
    required this.totalCost,
    required this.features,
    required this.capacity,
    required this.warranty,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.addedBy,
    required this.adminStatus,
    required this.categoryName,
    required this.subcategoryName,
    required this.totalEnquiry,
    required this.unreadEnquiry,
  });

  factory MyProductModel.fromJson(Map<String, dynamic> json) {
    int parseEnquiry(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) {
        return int.tryParse(val) ?? 0;
      }
      return 0;
    }

    return MyProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      subcategoryId: json['subcategory_id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      metaImage: json['meta_image'] as String? ?? '',
      galleryImages: (json['gallery_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      price: json['price'] as String? ?? '0.00',
      discount: json['discount'] as String? ?? '0.00',
      totalCost: json['total_cost'] as String? ?? '0.00',
      features: json['features'] as String? ?? '',
      capacity: json['capacity'] as String? ?? '',
      warranty: json['warranty'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      addedBy: json['added_by'] as int? ?? 0,
      adminStatus: json['admin_status'] as String? ?? 'pending',
      categoryName: json['category_name'] as String? ?? '',
      subcategoryName: json['subcategory_name'] as String? ?? '',
      totalEnquiry: parseEnquiry(json['total_enquiry']),
      unreadEnquiry: parseEnquiry(json['unread_enquiry']),
    );
  }
}
