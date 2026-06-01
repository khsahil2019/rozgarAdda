import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rojgar/models/explore_model.dart';

class CategoryApiException implements Exception {
  final String message;

  const CategoryApiException(this.message);

  @override
  String toString() => message;
}

class CategoryApiService {
  static const String _endpoint = 'https://rozgaradda.com/api/categories';

  Future<List<DashboardCategory>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));

      if (response.statusCode != 200) {
        throw const CategoryApiException(
          'Unable to load categories. Please try again.',
        );
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final rawList = decoded['data'] as List<dynamic>? ?? <dynamic>[];

      return rawList
          .map(
            (item) => DashboardCategory.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (error) {
      if (error is CategoryApiException) {
        rethrow;
      }

      throw const CategoryApiException(
        'Unable to load categories. Please check your connection.',
      );
    }
  }
}
