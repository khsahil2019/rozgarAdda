import 'package:get/get.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/domain/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository = Get.find<AuthRepository>();

  Future<AuthResponse> login(String email, String password) async {
    final either = await authRepository.login(email, password);
    return either.fold((failure) => throw failure, (res) => res);
  }

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
    required String otp,
  }) async {
    final either = await authRepository.register(
      fullName: fullName,
      phone: phone,
      email: email,
      username: username,
      password: password,
      state: state,
      district: district,
      locality: locality,
      pincode: pincode,
      address: address,
      otp: otp,
    );
    return either.fold((failure) => throw failure, (res) => res);
  }
}
