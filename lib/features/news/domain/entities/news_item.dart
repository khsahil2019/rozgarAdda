sealed class NewsItem {
  final int id;
  final String title;
  final DateTime createdAt;

  const NewsItem({
    required this.id,
    required this.title,
    required this.createdAt,
  });
}

class TextNews extends NewsItem {
  final String category;
  final String description;
  final String imageUrl;
  final String imagePath;
  final String status;
  final bool isSeen;
  final int addedBy;

  const TextNews({
    required super.id,
    required super.title,
    required super.createdAt,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.imagePath,
    required this.status,
    required this.isSeen,
    required this.addedBy,
  });
}

class VideoNews extends NewsItem {
  final String subject;
  final String videoUrl;
  final String videoPath;
  final int addedBy;
  final String status;

  const VideoNews({
    required super.id,
    required super.title,
    required super.createdAt,
    required this.subject,
    required this.videoUrl,
    required this.videoPath,
    required this.addedBy,
    required this.status,
  });
}

class YoutubeNews extends NewsItem {
  final String youtubeUrl;
  final String description;
  final String thumbnailUrl;
  final String youtubeId;
  final DateTime updatedAt;

  const YoutubeNews({
    required super.id,
    required super.title,
    required super.createdAt,
    required this.youtubeUrl,
    required this.description,
    required this.thumbnailUrl,
    required this.youtubeId,
    required this.updatedAt,
  });
}
