import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rojgar/models/job_role_model.dart';

class JobRoleApiException implements Exception {
  final String message;

  const JobRoleApiException(this.message);

  @override
  String toString() => message;
}

class JobRoleApiService {
  static const String _endpoint =
      'https://rozgaradda.com/api/candidate/job-roles';

  Future<List<JobRole>> fetchJobRoles(int subCategoryId) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'category_id': subCategoryId}),
      );

      if (response.statusCode != 200) {
        throw const JobRoleApiException(
          'Unable to load job roles. Please try again.',
        );
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final success = decoded['status'] == true || decoded['success'] == true;
      if (!success) {
        throw JobRoleApiException(
          (decoded['message'] ?? 'Unable to load job roles.').toString(),
        );
      }

      final data = decoded['data'] as List<dynamic>? ?? <dynamic>[];
      final newList = data
          .map((item) => JobRole.fromJson(item as Map<String, dynamic>))
          .toList();
      return newList;
    } catch (error) {
      if (error is JobRoleApiException) {
        rethrow;
      }

      throw const JobRoleApiException(
        'Unable to load job roles. Please check your connection.',
      );
    }
  }
}
