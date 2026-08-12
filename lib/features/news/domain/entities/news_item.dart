sealed class NewsItem {
  final int id;
  final String title;
  final DateTime createdAt;
  final int categoryId;
  final int stateId;
  final String categoryName;
  final String stateName;

  const NewsItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.categoryId,
    required this.stateId,
    required this.categoryName,
    required this.stateName,
  });
}

class TextNews extends NewsItem {
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
    required super.categoryId,
    required super.stateId,
    required super.categoryName,
    required super.stateName,
    required this.description,
    required this.imageUrl,
    required this.imagePath,
    required this.status,
    required this.isSeen,
    required this.addedBy,
  });
}

class VideoNews extends NewsItem {
  final String description;
  final String videoUrl;
  final String videoPath;
  final String thumbnailUrl;
  final int addedBy;
  final String status;

  const VideoNews({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.categoryId,
    required super.stateId,
    required super.categoryName,
    required super.stateName,
    required this.description,
    required this.videoUrl,
    required this.videoPath,
    required this.thumbnailUrl,
    required this.addedBy,
    required this.status,
  });
}
