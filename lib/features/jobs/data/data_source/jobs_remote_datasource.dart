import 'package:flutter/foundation.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/storage_service.dart';
import '../../../auth/data/data_source/model/dropdown_item.dart';
import '../model/available_job_model.dart';
import '../model/job_category_model.dart';
import '../model/job_role_model.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobCategoryModel>> getCategories();
  Future<List<JobRoleModel>> getJobRoles(int categoryId);
  Future<List<AvailableJobModel>> getAvailableJobs(
    int roleId, {
    int? stateId,
    int? districtId,
    int? localityId,
  });
  Future<List<AvailableJobModel>> getLatestJobs({
    int? stateId,
    int? districtId,
    int? localityId,
  });
  Future<List<DropdownItem>> getStates();
  Future<List<DropdownItem>> getDistricts(int stateId);
  Future<List<DropdownItem>> getLocalities(int districtId);
  Future<bool> applyJob({
    required int jobId,
    required String token,
    required Map<String, String> fields,
    required String resumePath,
  });
  Future<bool> logCallAndChatApply({
    required int jobId,
    required String type,
    required String phoneNo,
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
      throw Failure(
        'Failed to fetch categories. Please check your connection.',
      );
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
  Future<List<AvailableJobModel>> getAvailableJobs(
    int roleId, {
    int? stateId,
    int? districtId,
    int? localityId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (stateId != null) queryParams['state'] = stateId;
      if (districtId != null) queryParams['district'] = districtId;
      if (localityId != null) queryParams['locality'] = localityId;

      final res = await ApiService.get(
        ApiRoutes.availableJobs(roleId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
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
      throw Failure(
        'Failed to fetch available jobs. Please check your connection.',
      );
    }
  }

  @override
  Future<List<AvailableJobModel>> getLatestJobs({
    int? stateId,
    int? districtId,
    int? localityId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageService.keyAccessToken) ??
        prefs.getString('access_token') ??
        prefs.getString('employer_token') ??
        prefs.getString('candidate_token');

    final effectiveStateId = stateId ?? prefs.getInt('selected_state_id');

    final Map<String, dynamic> queryParams = {};
    if (effectiveStateId != null) {
      queryParams['state'] = effectiveStateId;
      queryParams['state_id'] = effectiveStateId;
    }
    if (districtId != null) {
      queryParams['district'] = districtId;
      queryParams['district_id'] = districtId;
    }
    if (localityId != null) {
      queryParams['locality'] = localityId;
      queryParams['locality_id'] = localityId;
      queryParams['localite_id'] = localityId;
    }

    debugPrint('[LatestJobsDebug] Requesting: ${ApiRoutes.latestJobs}');
    debugPrint('[LatestJobsDebug] Token available: ${token != null && token.isNotEmpty}');
    debugPrint('[LatestJobsDebug] Query params: $queryParams');

    // Helper to safely extract list of jobs from any response format
    List<dynamic> extractJobsList(dynamic response) {
      if (response == null) return [];
      if (response is List) return response;
      if (response is Map<String, dynamic>) {
        if (response['data'] is List) return response['data'] as List<dynamic>;
        if (response['data'] is Map && response['data']['data'] is List) {
          return response['data']['data'] as List<dynamic>;
        }
        if (response['jobs'] is List) return response['jobs'] as List<dynamic>;
        if (response['jobs'] is Map && response['jobs']['data'] is List) {
          return response['jobs']['data'] as List<dynamic>;
        }
      }
      return [];
    }

    try {
      final res = await ApiService.get(
        ApiRoutes.latestJobs,
        accessToken: token,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      debugPrint('[LatestJobsDebug] Status code: ${res['statusCode']}');
      debugPrint('[LatestJobsDebug] Response status: ${res['status']}');
      debugPrint('[LatestJobsDebug] Response message: ${res['message']}');

      final isSuccess = res['statusCode'] == 200 &&
          (res['status'] == true || res['success'] == true);

      final rawJobs = extractJobsList(res);

      if (isSuccess && rawJobs.isNotEmpty) {
        final List<AvailableJobModel> jobs = [];
        for (final item in rawJobs) {
          if (item is Map<String, dynamic>) {
            try {
              jobs.add(AvailableJobModel.fromJson(item));
            } catch (parseError) {
              debugPrint('[LatestJobsDebug] Parse warning for job: $parseError');
            }
          }
        }
        if (jobs.isNotEmpty) return jobs;
      }

      // If response says "no jobs" or "not found", treat cleanly as empty
      final msg = (res['message'] ?? '').toString().toLowerCase();
      if (msg.contains('no jobs') ||
          msg.contains('not found') ||
          msg.contains('empty') ||
          msg.contains('error fetching')) {
        debugPrint('[LatestJobsDebug] Cleanly returning empty list for: $msg');
        return [];
      }

      // If status was false and message exists, fall through to fallback
      debugPrint('[LatestJobsDebug] API returned unsuccessful message: ${res['message']}');
    } catch (e) {
      debugPrint('[LatestJobsDebug] Primary latest-jobs request note: $e');
    }

    // ── FALLBACK 1: Try Employer Jobs if user has employer token ───────────
    final employerToken = prefs.getString('employer_token');
    if (employerToken != null && employerToken.isNotEmpty) {
      try {
        debugPrint('[LatestJobsDebug] Trying fallback to employer jobs endpoint...');
        final empRes = await ApiService.get(
          ApiRoutes.employerJobs,
          accessToken: employerToken,
        );
        final rawJobs = extractJobsList(empRes);
        if (rawJobs.isNotEmpty) {
          final List<AvailableJobModel> jobs = [];
          for (final item in rawJobs) {
            if (item is Map<String, dynamic>) {
              try {
                jobs.add(AvailableJobModel.fromJson(item));
              } catch (_) {}
            }
          }
          if (jobs.isNotEmpty) {
            debugPrint('[LatestJobsDebug] Fallback succeeded with ${jobs.length} employer jobs');
            return jobs;
          }
        }
      } catch (e) {
        debugPrint('[LatestJobsDebug] Employer jobs fallback note: $e');
      }
    }

    // ── FALLBACK 2: Try Available Jobs for popular roles ──────────────────
    try {
      debugPrint('[LatestJobsDebug] Trying fallback via available-jobs for active roles...');
      for (final roleId in [1, 2, 3, 4, 5, 6, 7, 8]) {
        try {
          final availJobs = await getAvailableJobs(
            roleId,
            stateId: effectiveStateId,
            districtId: districtId,
            localityId: localityId,
          );
          if (availJobs.isNotEmpty) {
            debugPrint('[LatestJobsDebug] Fallback found ${availJobs.length} jobs in role $roleId');
            return availJobs;
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[LatestJobsDebug] Role fallback note: $e');
    }

    // If nothing found or backend server error, return empty list so screen shows empty state
    return [];
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
      throw Failure(
        'Failed to submit application. Please check your connection.',
      );
    }
  }

  @override
  Future<bool> logCallAndChatApply({
    required int jobId,
    required String type,
    required String phoneNo,
  }) async {
    try {
      final res = await ApiService.post(
        ApiRoutes.callAndChatApply(jobId),
        body: {'type': type, 'phone': phoneNo},
      );
      if (res['statusCode'] == 200 &&
          (res['status'] == true || res['success'] == true)) {
        return true;
      } else {
        throw Failure(res['message'] ?? 'Failed to log call/chat apply');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(
        'Failed to log call/chat apply. Please check your connection.',
      );
    }
  }

  @override
  Future<List<DropdownItem>> getStates() async {
    try {
      final res = await ApiService.get('https://rozgaradda.com/api/states');
      if (res['statusCode'] == 200) {
        final List<dynamic> data = res['data'] as List<dynamic>? ?? <dynamic>[];
        return data
            .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch states');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure("Failed to fetch states");
    }
  }

  @override
  Future<List<DropdownItem>> getDistricts(int stateId) async {
    try {
      final res = await ApiService.get(
        'https://rozgaradda.com/api/districts/$stateId',
      );
      if (res['statusCode'] == 200) {
        final List<dynamic> data = res['data'] as List<dynamic>? ?? <dynamic>[];
        return data
            .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch districts');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure("Failed to fetch districts");
    }
  }

  @override
  Future<List<DropdownItem>> getLocalities(int districtId) async {
    try {
      final res = await ApiService.get(
        'https://rozgaradda.com/api/localities/$districtId',
      );
      if (res['statusCode'] == 200) {
        final List<dynamic> data = res['data'] as List<dynamic>? ?? <dynamic>[];
        return data
            .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch localities');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure("Failed to fetch localities");
    }
  }
}
