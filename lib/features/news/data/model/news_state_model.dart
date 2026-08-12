import '../../domain/entities/news_state.dart';

class NewsStateModel {
  final int id;
  final String name;

  NewsStateModel({required this.id, required this.name});

  factory NewsStateModel.fromJson(Map<String, dynamic> json) {
    return NewsStateModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  NewsState toEntity() => NewsState(id: id, name: name);
}
