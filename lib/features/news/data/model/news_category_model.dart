import '../../domain/entities/news_category.dart';

class NewsCategoryModel {
  final int id;
  final String name;
  final String slug;

  NewsCategoryModel({required this.id, required this.name, required this.slug});

  factory NewsCategoryModel.fromJson(Map<String, dynamic> json) {
    return NewsCategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }

  NewsCategory toEntity() => NewsCategory(id: id, name: name, slug: slug);
}
