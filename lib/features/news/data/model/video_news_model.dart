import '../../domain/entities/news_item.dart';

class VideoNewsModel {
  final int id;
  final String title;
  final String subject;
  final String video;
  final int addedBy;
  final String status;
  final String createdAt;

  VideoNewsModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.video,
    required this.addedBy,
    required this.status,
    required this.createdAt,
  });

  factory VideoNewsModel.fromJson(Map<String, dynamic> json) {
    return VideoNewsModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      video: json['video'] as String? ?? '',
      addedBy: json['added_by'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  VideoNews toEntity() {
    // Normalise slashes in relative video path
    final String cleanVideoPath = video.replaceAll(r'\/', '/');
    return VideoNews(
      id: id,
      title: title,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      subject: subject,
      videoUrl: 'https://rozgaradda.com/$cleanVideoPath',
      videoPath: video,
      addedBy: addedBy,
      status: status,
    );
  }
}
