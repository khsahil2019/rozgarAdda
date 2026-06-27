import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/storage_service.dart';
import '../model/available_job_model.dart';
import '../model/job_category_model.dart';
import '../model/job_role_model.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobCategoryModel>> getCategories();
  Future<List<JobRoleModel>> getJobRoles(int categoryId);
  Future<List<AvailableJobModel>> getAvailableJobs(int roleId);
  Future<List<AvailableJobModel>> getLatestJobs();
  Future<bool> applyJob({
    required int jobId,
    required String token,
    required Map<String, String> fields,
    required String resumePath,
  });
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  @override
  Future<List<JobCategoryModel>> getCategories() async {
    try {
      final res = await ApiService.get(ApiRoutes.dashboard);
      if (res['statusCode'] == 200 && res['status'] == true) {
        final data = res['data'] as Map<String, dynamic>? ?? {};
        final rawList = data['categories'] as List<dynamic>? ?? [];
        return rawList
            .map((e) => JobCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch categories. Please check your connection.');
    }
  }

  @override
  Future<List<JobRoleModel>> getJobRoles(int categoryId) async {
    try {
      final res = await ApiService.post(
        ApiRoutes.jobRoles,
        body: {'category_id': categoryId},
      );
      if (res['statusCode'] == 200 &&
          (res['status'] == true || res['success'] == true)) {
        final List<dynamic> dataList = res['data'] as List<dynamic>? ?? [];
        return dataList
            .map((e) => JobRoleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch job roles');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch job roles. Please check your connection.');
    }
  }

  @override
  Future<List<AvailableJobModel>> getAvailableJobs(int roleId) async {
    try {
      final res = await ApiService.get(ApiRoutes.availableJobs(roleId));
      if (res['statusCode'] == 200 && res['status'] == true) {
        final List<dynamic> dataList = res['data'] as List<dynamic>? ?? [];
        return dataList
            .map((e) => AvailableJobModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch available jobs');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch available jobs. Please check your connection.');
    }
  }

  @override
  Future<List<AvailableJobModel>> getLatestJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageService.keyAccessToken);
      final res = await ApiService.get(
        ApiRoutes.latestJobs,
        accessToken: token,
      );
      if (res['statusCode'] == 200 && res['status'] == true) {
        final List<dynamic> dataList = res['data'] as List<dynamic>? ?? [];
        return dataList
            .map((e) => AvailableJobModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch latest jobs');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch latest jobs. Please check your connection.');
    }
  }

  @override
  Future<bool> applyJob({
    required int jobId,
    required String token,
    required Map<String, String> fields,
    required String resumePath,
  }) async {
    try {
      final res = await ApiService.uploadFiles(
        method: 'POST',
        url: ApiRoutes.applyJob(jobId),
        accessToken: token,
        fields: fields,
        files: {'resume': resumePath},
      );
      if (res['statusCode'] == 200 &&
          (res['status'] == true || res['success'] == true)) {
        return true;
      } else {
        throw Failure(res['message'] ?? 'Failed to submit application');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to submit application. Please check your connection.');
    }
  }
}

