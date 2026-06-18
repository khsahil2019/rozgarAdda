import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repositories/employer_auth_repository.dart';

class EmployerLoginController extends GetxController {
  final EmployerAuthRepository authRepository;

  EmployerLoginController({required this.authRepository});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordObscured = true.obs;
  final RxBool acceptedTerms = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(() {
      email.value = emailController.text;
    });
    passwordController.addListener(() {
      password.value = passwordController.text;
    });
  }

  @override
  void onClose() {
    emailController.dispose();
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
      email.value.trim().isNotEmpty &&
      password.value.isNotEmpty &&
      acceptedTerms.value &&
      !isLoading.value;

  Future<void> login({
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    if (!isLoginEnabled) return;
    isLoading.value = true;
    
    final result = await authRepository.login(
      email.value.trim(),
      password.value,
    );

    result.fold(
      (failure) {
        isLoading.value = false;
        onError(failure.message);
      },
      (employer) {
        isLoading.value = false;
        onSuccess();
      },
    );
  }
}
