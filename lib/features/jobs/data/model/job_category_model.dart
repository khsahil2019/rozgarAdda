import '../../domain/entities/job_category.dart';

class JobCategoryModel {
  final int id;
  final String name;
  final String image;

  JobCategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobCategoryModel(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }

  JobCategory toEntity() {
    String imageUrl = image;
    if (imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://')) {
      imageUrl = 'https://rozgaradda.com/categories/$imageUrl';
    }
    return JobCategory(
      id: id,
      name: name,
      imageUrl: imageUrl,
    );
  }
}
