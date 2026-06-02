import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register({
    required String fullName,
    required String phone,
    required String email,
    required String username,
    required String password,
    required String state,
    required String district,
    required String locality,
    required String pincode,
    required String address,
  });
  Future<List<DropdownItem>> getStates();
  Future<List<DropdownItem>> getDistricts(int stateId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await ApiService.post(
        ApiRoutes.login,
        body: {"username": email, "password": password},
      );
      if ((res['statusCode'] == 200 || res['statusCode'] == 201) &&
          res['status'] == true) {
        return AuthResponse.fromJson(res);
      } else {
        throw Failure(res['message'] ?? res['error'] ?? 'Something went wrong');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure("Something went wrong");
    }
  }

  @override
  Future<AuthResponse> register({
    required String fullName,
    required String phone,
    required String email,
    required String username,
    required String password,
    required String state,
    required String district,
    required String locality,
    required String pincode,
    required String address,
  }) async {
    try {
      final res = await ApiService.post(
        ApiRoutes.register,
        body: {
          'full_name': fullName,
          'phone': phone,
          'email': email,
          'username': username,
          'password': password,
          'state': state,
          'district': district,
          'locality': locality,
          'pincode': pincode,
          'address': address,
        },
      );
      if ((res['statusCode'] == 200 || res['statusCode'] == 201) &&
          res['status'] == true) {
        return AuthResponse.fromJson(res);
      } else {
        throw Failure(res['message'] ?? res['error'] ?? 'Something went wrong');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure("Something went wrong");
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
}
