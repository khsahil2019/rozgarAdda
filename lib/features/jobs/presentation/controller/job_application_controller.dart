import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repository/jobs_repository.dart';

class JobApplicationController extends GetxController {
  final JobsRepository repository;

  JobApplicationController({required this.repository});

  final formKey = GlobalKey<FormState>();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final experienceYearsCtrl = TextEditingController();
  final experienceMonthsCtrl = TextEditingController();
  final expectedSalaryCtrl = TextEditingController();
  final noticePeriodCtrl = TextEditingController();
  final educationLevelCtrl = TextEditingController();
  final educationDetailsCtrl = TextEditingController();
  final keySkillsCtrl = TextEditingController();

  final Rxn<PlatformFile> resumeFile = Rxn<PlatformFile>();
  final RxBool agreed = false.obs;
  final RxBool isSubmitting = false.obs;

  void clearFields() {
    firstNameCtrl.clear();
    lastNameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    experienceYearsCtrl.clear();
    experienceMonthsCtrl.clear();
    expectedSalaryCtrl.clear();
    noticePeriodCtrl.clear();
    educationLevelCtrl.clear();
    educationDetailsCtrl.clear();
    keySkillsCtrl.clear();
    resumeFile.value = null;
    agreed.value = false;
    isSubmitting.value = false;
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    experienceYearsCtrl.dispose();
    experienceMonthsCtrl.dispose();
    expectedSalaryCtrl.dispose();
    noticePeriodCtrl.dispose();
    educationLevelCtrl.dispose();
    educationDetailsCtrl.dispose();
    keySkillsCtrl.dispose();
    super.onClose();
  }

  Future<void> pickResume() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null || file.path!.isEmpty) {
      Get.snackbar(
        'Error',
        'Unable to read selected file.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      Get.snackbar(
        'Error',
        'Resume must be under 10MB.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }
    resumeFile.value = file;
  }

  Future<void> submitApplication(int jobId, VoidCallback onSuccess) async {
    if (!formKey.currentState!.validate()) return;
    if (resumeFile.value?.path == null) {
      Get.snackbar(
        'Error',
        'Please upload your resume.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }
    if (!agreed.value) {
      Get.snackbar(
        'Error',
        'Please accept terms to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final fullName =
          '${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}'.trim();

      final result = await repository.applyJob(
        jobId: jobId,
        fullName: fullName,
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        experienceYears: experienceYearsCtrl.text.trim(),
        experienceMonths: experienceMonthsCtrl.text.trim(),
        expectedSalary: expectedSalaryCtrl.text.trim(),
        noticePeriod: noticePeriodCtrl.text.trim(),
        educationLevel: educationLevelCtrl.text.trim(),
        educationDetails: educationDetailsCtrl.text.trim(),
        keySkills: keySkillsCtrl.text.trim(),
        resumePath: resumeFile.value!.path!,
      );

      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white,
          );
        },
        (success) {
          Get.snackbar(
            'Success',
            'Application submitted successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1A1AE6).withValues(alpha: 0.8),
            colorText: Colors.white,
          );
          onSuccess();
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
