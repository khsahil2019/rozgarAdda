import 'package:rojgar/core/network/api_routes.dart';
import '../../domain/entities/news_item.dart';

class VideoNewsModel {
  final int id;
  final String title;
  final int categoryId;
  final int stateId;
  final String categoryName;
  final String stateName;
  final String description;
  final String video;
  final String videoUrl;
  final String thumbnailUrl;
  final int addedBy;
  final String status;
  final String createdAt;

  VideoNewsModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.stateId,
    required this.categoryName,
    required this.stateName,
    required this.description,
    required this.video,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.addedBy,
    required this.status,
    required this.createdAt,
  });

  factory VideoNewsModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final state = json['state'] as Map<String, dynamic>?;
    return VideoNewsModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? category?['id'] as int? ?? 0,
      stateId: json['state_id'] as int? ?? state?['id'] as int? ?? 0,
      categoryName: category?['name'] as String? ?? '',
      stateName: state?['name'] as String? ?? '',
      // The listing still labels the body `subject`; accept `description` too.
      description:
          json['description'] as String? ?? json['subject'] as String? ?? '',
      video: json['video'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl:
          json['thumbnail_url'] as String? ??
          json['image_url'] as String? ??
          '',
      addedBy: json['added_by'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  VideoNews toEntity() {
    final rawVideo = (videoUrl.isNotEmpty ? videoUrl : video).replaceAll(
      r'\/',
      '/',
    );
    return VideoNews(
      id: id,
      title: title,
      createdAt: DateTime.tryParse(createdAt)?.toLocal() ?? DateTime.now(),
      categoryId: categoryId,
      stateId: stateId,
      categoryName: categoryName,
      stateName: stateName,
      description: description,
      videoUrl: ApiRoutes.absoluteUrl(rawVideo),
      videoPath: video,
      thumbnailUrl: ApiRoutes.absoluteUrl(thumbnailUrl),
      addedBy: addedBy,
      status: status,
    );
  }
}
