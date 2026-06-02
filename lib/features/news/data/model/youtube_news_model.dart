import '../../domain/entities/news_item.dart';

class YoutubeNewsModel {
  final int id;
  final String title;
  final String youtubeUrl;
  final String description;
  final String thumbnailUrl;
  final String youtubeId;
  final String createdAt;
  final String updatedAt;

  YoutubeNewsModel({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.description,
    required this.thumbnailUrl,
    required this.youtubeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory YoutubeNewsModel.fromJson(Map<String, dynamic> json) {
    return YoutubeNewsModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      youtubeUrl: json['youtube_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      youtubeId: json['youtube_id'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  YoutubeNews toEntity() {
    return YoutubeNews(
      id: id,
      title: title,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      youtubeUrl: youtubeUrl,
      description: description,
      thumbnailUrl: thumbnailUrl,
      youtubeId: youtubeId,
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
    );
  }
}
