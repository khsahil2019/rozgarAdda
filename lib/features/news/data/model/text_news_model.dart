import 'package:rojgar/core/network/api_routes.dart';
import '../../domain/entities/news_item.dart';

class TextNewsModel {
  final int id;
  final String title;
  final int categoryId;
  final int stateId;
  final String categoryName;
  final String stateName;
  final String description;
  final String image;
  final String imageUrl;
  final String status;
  final int isSeen;
  final int addedBy;
  final String createdAt;

  TextNewsModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.stateId,
    required this.categoryName,
    required this.stateName,
    required this.description,
    required this.image,
    required this.imageUrl,
    required this.status,
    required this.isSeen,
    required this.addedBy,
    required this.createdAt,
  });

  factory TextNewsModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final state = json['state'] as Map<String, dynamic>?;
    return TextNewsModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? category?['id'] as int? ?? 0,
      stateId: json['state_id'] as int? ?? state?['id'] as int? ?? 0,
      categoryName:
          category?['name'] as String? ?? json['category'] as String? ?? '',
      stateName: state?['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isSeen: json['is_seen'] as int? ?? 0,
      addedBy: json['added_by'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  TextNews toEntity() {
    return TextNews(
      id: id,
      title: title,
      createdAt: DateTime.tryParse(createdAt)?.toLocal() ?? DateTime.now(),
      categoryId: categoryId,
      stateId: stateId,
      categoryName: categoryName,
      stateName: stateName,
      description: description,
      imageUrl: ApiRoutes.absoluteUrl(imageUrl.isNotEmpty ? imageUrl : image),
      imagePath: image,
      status: status,
      isSeen: isSeen == 1,
      addedBy: addedBy,
    );
  }
}
