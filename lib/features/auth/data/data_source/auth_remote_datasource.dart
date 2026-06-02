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
    String? identityProofPath,
  });
  Future<List<DropdownItem>> getStates();
  Future<List<DropdownItem>> getDistricts(int stateId);

  /// Sends an OTP to [phone]. Throws [Failure] on error.
  Future<void> sendOtp(String phone);

  /// Verifies [otp] for [phone]. Throws [Failure] on error.
  Future<void> verifyOtp(String phone, String otp);
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
    String? identityProofPath,
  }) async {
    try {
      final fields = {
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
      };

      Map<String, dynamic> res;
      if (identityProofPath != null && identityProofPath.isNotEmpty) {
        res = await ApiService.uploadFiles(
          method: 'POST',
          url: ApiRoutes.register,
          fields: fields,
          files: {'identity_proof': identityProofPath},
        );
      } else {
        res = await ApiService.post(
          ApiRoutes.register,
          body: fields,
        );
      }

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

  @override
  Future<void> sendOtp(String phone) async {
    try {
      final res = await ApiService.post(
        ApiRoutes.sendOtp,
        body: {'phone': int.tryParse(phone) ?? phone},
      );
      if (res['status'] == false) {
        throw Failure(res['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to send OTP. Please try again.');
    }
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      final res = await ApiService.post(
        ApiRoutes.verifyOtp,
        body: {'phone': phone, 'otp': otp},
      );
      if (res['status'] == false) {
        throw Failure(res['message'] ?? 'Invalid OTP. Please try again.');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('OTP verification failed. Please try again.');
    }
  }
}
