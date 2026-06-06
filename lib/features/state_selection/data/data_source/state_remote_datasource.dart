import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_services.dart';
import '../models/state_model.dart';

abstract class StateRemoteDataSource {
  Future<List<StateModel>> getStatesImages();
}

class StateRemoteDataSourceImpl implements StateRemoteDataSource {
  @override
  Future<List<StateModel>> getStatesImages() async {
    try {
      final res = await ApiService.get('https://rozgaradda.com/api/states-images');
      if (res['statusCode'] == 200) {
        final List<dynamic> data = (res['data'] as List?) ?? <dynamic>[];
        return data
            .map((e) => StateModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure('Unable to load states. Please try again.');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Unable to load states. Please check your connection.');
    }
  }
}
