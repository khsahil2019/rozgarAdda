import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';
import '../model/missing_person_model.dart';

abstract class MissingPersonRemoteDataSource {
  Future<List<MissingPersonModel>> getMissingPersons();
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
}
