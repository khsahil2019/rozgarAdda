import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repositories/employer_auth_repository.dart';

class EmployerRegisterController extends GetxController {
  final EmployerAuthRepository authRepository;

  EmployerRegisterController({required this.authRepository});

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final RxString companyName = ''.obs;
  final RxString contactPerson = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString password = ''.obs;
  final RxString address = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isPasswordObscured = true.obs;
  final RxBool acceptedTerms = false.obs;

  // ── File Upload ───────────────────────────────────────────────────────────
  final RxnString identityProofPath = RxnString();

  Future<void> pickIdentityProof() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        identityProofPath.value = result.files.single.path;
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    companyNameController.addListener(() => companyName.value = companyNameController.text);
    contactPersonController.addListener(() => contactPerson.value = contactPersonController.text);
    emailController.addListener(() => email.value = emailController.text);
    phoneController.addListener(() => phone.value = phoneController.text);
    passwordController.addListener(() => password.value = passwordController.text);
    addressController.addListener(() => address.value = addressController.text);
  }

  @override
  void onClose() {
    companyNameController.dispose();
    contactPersonController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void togglePasswordObscurity() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void toggleTermsAcceptance() {
    acceptedTerms.value = !acceptedTerms.value;
  }

  bool get isRegisterEnabled =>
      companyName.value.trim().isNotEmpty &&
      contactPerson.value.trim().isNotEmpty &&
      email.value.trim().isNotEmpty &&
      phone.value.trim().isNotEmpty &&
      password.value.isNotEmpty &&
      address.value.trim().isNotEmpty &&
      identityProofPath.value != null &&
      acceptedTerms.value &&
      !isLoading.value;

  Future<void> register({
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    if (!isRegisterEnabled) return;
    isLoading.value = true;

    final result = await authRepository.register(
      companyName: companyName.value.trim(),
      email: email.value.trim(),
      phone: phone.value.trim(),
      contactPerson: contactPerson.value.trim(),
      password: password.value,
      address: address.value.trim(),
      identityProofPath: identityProofPath.value,
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
