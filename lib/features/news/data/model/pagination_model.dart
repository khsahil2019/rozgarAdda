import '../../domain/entities/news_page.dart';

class PaginationModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  /// `per_page` comes back as a string on some endpoints, so parse loosely.
  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory PaginationModel.fromJson(
    Map<String, dynamic>? json, {
    int itemCount = 0,
  }) {
    if (json == null) {
      // Endpoint returned a flat list: treat it as a single complete page.
      return PaginationModel(
        currentPage: 1,
        perPage: itemCount,
        total: itemCount,
        lastPage: 1,
      );
    }
    return PaginationModel(
      currentPage: _toInt(json['current_page'], 1),
      perPage: _toInt(json['per_page'], itemCount),
      total: _toInt(json['total'], itemCount),
      lastPage: _toInt(json['last_page'], 1),
    );
  }

  NewsPagination toEntity() => NewsPagination(
    currentPage: currentPage,
    perPage: perPage,
    total: total,
    lastPage: lastPage,
  );
}
