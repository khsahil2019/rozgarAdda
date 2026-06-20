import 'package:shared_preferences/shared_preferences.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/services/storage_service.dart';
import '../model/missing_person_model.dart';

abstract class MissingPersonRemoteDataSource {
  Future<List<MissingPersonModel>> getMissingPersons();
  Future<String> addMissingPerson({
    required Map<String, String> fields,
    required Map<String, String> files,
  });
}

class MissingPersonRemoteDataSourceImpl implements MissingPersonRemoteDataSource {
  @override
  Future<List<MissingPersonModel>> getMissingPersons() async {
    try {
      final res = await ApiService.get(ApiRoutes.missingPersons);
      if (res['statusCode'] == 200 && res['status'] == true) {
        final List<dynamic> dataList = res['data'] as List<dynamic>? ?? [];
        return dataList
            .map((json) => MissingPersonModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch missing persons');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch missing persons: ${e.toString()}');
    }
  }

  @override
  Future<String> addMissingPerson({
    required Map<String, String> fields,
    required Map<String, String> files,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageService.keyAccessToken) ?? '';

      final res = await ApiService.uploadFiles(
        method: 'POST',
        url: ApiRoutes.missingPersons,
        fields: fields,
        files: files,
        accessToken: token,
      );

      if (res['statusCode'] == 200 || res['statusCode'] == 201) {
        if (res['status'] == false) {
          throw Failure(res['message'] ?? 'Failed to submit missing person details');
        }
        return res['message'] ?? 'Missing person details submitted successfully';
      } else {
        throw Failure(res['message'] ?? 'Server returned code ${res['statusCode']}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to submit missing person details: ${e.toString()}');
    }
  }
}
