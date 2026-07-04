import 'package:shared_preferences/shared_preferences.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';

abstract class EmployerDashboardRemoteDataSource {
  Future<void> changeApplicationStatus({
    required int applicationId,
    required String status,
    String? comments,
  });
}

class EmployerDashboardRemoteDataSourceImpl implements EmployerDashboardRemoteDataSource {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employer_token');
  }

  @override
  Future<void> changeApplicationStatus({
    required int applicationId,
    required String status,
    String? comments,
  }) async {
    try {
      final token = await _getToken();
      final url = '${ApiRoutes.baseUrl}/emp/application/$applicationId/change-status';
      
      final res = await ApiService.post(
        url,
        body: {
          'status': status,
          if (comments != null) 'comments': comments,
        },
        accessToken: token,
      );

      // The response payload example has {"success": true, "message": "...", "data": ...}
      if (res['success'] == true || res['status'] == true) {
        return;
      }
      throw Failure(res['message']?.toString() ?? 'Failed to update application status.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to update application status. Please check your connection.');
    }
  }
}
