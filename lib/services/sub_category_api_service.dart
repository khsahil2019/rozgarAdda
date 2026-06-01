import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rojgar/models/explore_model.dart';

class SubCategoryApiException implements Exception {
  final String message;

  const SubCategoryApiException(this.message);

  @override
  String toString() => message;
}

class SubCategoryApiService {
  static const String _endpoint = 'https://rozgaradda.com/api/subcategories';

  Future<List<DashboardSubCategory>> fetchSubCategories(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('$_endpoint/$categoryId'));

      if (response.statusCode != 200) {
        throw const SubCategoryApiException(
          'Unable to load sub-categories. Please try again.',
        );
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final success = decoded['success'] == true || decoded['status'] == true;
      if (!success) {
        throw SubCategoryApiException(
          (decoded['message'] ?? 'Unable to load sub-categories.').toString(),
        );
      }

      final rawList = decoded['data'] as List<dynamic>? ?? <dynamic>[];
      return rawList
          .map(
            (item) =>
                DashboardSubCategory.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (error) {
      if (error is SubCategoryApiException) {
        rethrow;
      }

      throw const SubCategoryApiException(
        'Unable to load sub-categories. Please check your connection.',
      );
    }
  }
}
