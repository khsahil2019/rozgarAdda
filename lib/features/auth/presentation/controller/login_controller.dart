import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/domain/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;

  LoginController({required this.authRepository});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxString username = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordObscured = true.obs;
  final RxBool acceptedTerms = false.obs;

  @override
  void onInit() {
    super.onInit();
    usernameController.addListener(() {
      username.value = usernameController.text;
    });
    passwordController.addListener(() {
      password.value = passwordController.text;
    });
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordObscurity() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void toggleTermsAcceptance() {
    acceptedTerms.value = !acceptedTerms.value;
  }

  bool get isLoginEnabled =>
      username.value.trim().isNotEmpty &&
      password.value.isNotEmpty &&
      acceptedTerms.value &&
      !isLoading.value;

  Future<AuthResponse> login() async {
    isLoading.value = true;
    try {
      final eitherResult = await authRepository.login(
        username.value.trim(),
        password.value,
      );

      return await eitherResult.fold(
        (failure) => throw failure,
        (result) async {
          // Persist user properties and update AppController state
          try {
            if (Get.isRegistered<AppController>()) {
              AppController.to.login(result);
            } else {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('candidate_id', result.id);
              await prefs.setString('access_token', result.token);
            }
          } catch (_) {
            // Ignore persistence issues
          }
          return result;
        },
      );
    } finally {
      isLoading.value = false;
    }
  }
}
