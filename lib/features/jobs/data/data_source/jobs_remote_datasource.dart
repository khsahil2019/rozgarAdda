import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_services.dart';
import '../model/job_category_model.dart';
import '../model/job_role_model.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobCategoryModel>> getCategories();
  Future<List<JobRoleModel>> getJobRoles(int categoryId);
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  @override
  Future<List<JobCategoryModel>> getCategories() async {
    try {
      final res = await ApiService.get(
        'https://rozgaradda.com/api/candidate/dashboard',
      );
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
        'https://rozgaradda.com/api/candidate/job-roles',
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
}
