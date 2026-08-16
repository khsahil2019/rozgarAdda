import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/application_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<ApplicationModel>> getApplications();
  Future<String> editProfile({
    required Map<String, String> fields,
    Map<String, String>? files,
  });
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<String> submitInquiry({
    required String name,
    required String mobile,
    required String email,
    required String subject,
    required String message,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageService.keyAccessToken);
  }

  @override
  Future<List<ApplicationModel>> getApplications() async {
    try {
      final token = await _getToken();
      final res = await ApiService.get(
        ApiRoutes.myApplications,
        accessToken: token,
      );
      if (res['status'] == true) {
        final rawList = res['data'] as List<dynamic>? ?? [];
        return rawList
            .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Failure(res['message']?.toString() ?? 'Failed to fetch applications');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch applications. Please check your connection.');
    }
  }

  @override
  Future<String> editProfile({
    required Map<String, String> fields,
    Map<String, String>? files,
  }) async {
    try {
      final token = await _getToken();
      final res = await ApiService.uploadFiles(
        method: 'POST',
        url: ApiRoutes.editProfile,
        fields: fields,
        files: files ?? {},
        accessToken: token,
      );
      if (res['status'] == true) {
        return res['message']?.toString() ?? 'Profile updated successfully';
      }
      throw Failure(res['message']?.toString() ?? 'Failed to update profile');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to update profile. Please check your connection.');
    }
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final token = await _getToken();
      final res = await ApiService.post(
        ApiRoutes.changePassword,
        accessToken: token,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );
      if (res['status'] == true) {
        return res['message']?.toString() ?? 'Password changed successfully';
      }
      throw Failure(res['message']?.toString() ?? 'Failed to change password');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to change password. Please check your connection.');
    }
  }

  @override
  Future<String> submitInquiry({
    required String name,
    required String mobile,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final res = await ApiService.post(
        ApiRoutes.inquiry,
        body: {
          'name': name,
          'mobile': mobile,
          'email': email,
          'subject': subject,
          'message': message,
        },
      );
      if (res['status'] == true) {
        return res['message']?.toString() ?? 'Inquiry submitted successfully';
      }
      throw Failure(res['message']?.toString() ?? 'Failed to submit inquiry');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to submit inquiry. Please check your connection.');
    }
  }
}
