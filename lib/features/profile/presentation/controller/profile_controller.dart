import 'package:get/get.dart';
import 'package:rojgar/features/profile/domain/entities/application_entity.dart';
import 'package:rojgar/features/profile/domain/repository/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;

  ProfileController({required ProfileRepository repository})
    : _repository = repository;

  // ── My Applications ──────────────────────────────────────────────────
  final applications = <ApplicationEntity>[].obs;
  final isLoadingApplications = false.obs;
  final applicationsError = RxnString();

  Future<void> loadApplications() async {
    isLoadingApplications.value = true;
    applicationsError.value = null;
    final result = await _repository.getApplications();
    result.fold(
      (failure) => applicationsError.value = failure.message,
      (data) => applications.assignAll(data),
    );
    isLoadingApplications.value = false;
  }

  // ── Edit Profile ─────────────────────────────────────────────────────
  final isUpdatingProfile = false.obs;

  Future<String?> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String state,
    required String district,
    required String locality,
    required String pincode,
    required String address,
    String? idProofPath,
    String? resumePath,
    String? profilePhotoPath,
  }) async {
    isUpdatingProfile.value = true;
    final result = await _repository.editProfile(
      fullName: fullName,
      email: email,
      phone: phone,
      state: state,
      district: district,
      locality: locality,
      pincode: pincode,
      address: address,
      idProofPath: idProofPath,
      resumePath: resumePath,
      profilePhotoPath: profilePhotoPath,
    );
    isUpdatingProfile.value = false;
    return result.fold((f) {
      Get.snackbar('Error', f.message, snackPosition: SnackPosition.BOTTOM);
      return null;
    }, (msg) => msg);
  }

  // ── Change Password ──────────────────────────────────────────────────
  final isChangingPassword = false.obs;

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    isChangingPassword.value = true;
    final result = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
    isChangingPassword.value = false;
    return result.fold((f) {
      Get.snackbar('Error', f.message, snackPosition: SnackPosition.BOTTOM);
      return null;
    }, (msg) => msg);
  }

  // ── Help & Support / Inquiry ─────────────────────────────────────────
  final isSubmittingInquiry = false.obs;

  Future<String?> submitInquiry({
    required String name,
    required String mobile,
    required String email,
    required String subject,
    required String message,
  }) async {
    isSubmittingInquiry.value = true;
    final result = await _repository.submitInquiry(
      name: name,
      mobile: mobile,
      email: email,
      subject: subject,
      message: message,
    );
    isSubmittingInquiry.value = false;
    return result.fold((f) {
      Get.snackbar('Error', f.message, snackPosition: SnackPosition.BOTTOM);
      return null;
    }, (msg) => msg);
  }
}
