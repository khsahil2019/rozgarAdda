import '../../domain/entities/news_item.dart';

class TextNewsModel {
  final int id;
  final String title;
  final String category;
  final String description;
  final String image;
  final String status;
  final int isSeen;
  final int addedBy;
  final String createdAt;
  final String imageUrl;

  TextNewsModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.image,
    required this.status,
    required this.isSeen,
    required this.addedBy,
    required this.createdAt,
    required this.imageUrl,
  });

  factory TextNewsModel.fromJson(Map<String, dynamic> json) {
    return TextNewsModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isSeen: json['is_seen'] as int? ?? 0,
      addedBy: json['added_by'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  TextNews toEntity() {
    return TextNews(
      id: id,
      title: title,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      category: category,
      description: description,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://rozgaradda.com/$image',
      imagePath: image,
      status: status,
      isSeen: isSeen == 1,
      addedBy: addedBy,
    );
  }
}
