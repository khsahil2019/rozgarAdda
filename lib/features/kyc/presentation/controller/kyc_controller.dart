import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/kyc_models.dart';
import '../../domain/repository/kyc_repository.dart';
import 'uploaded_kyc_file.dart';

class KycController extends GetxController {
  final KycRepository repository;

  KycController({required this.repository});

  // Text Controllers
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final localityCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  // Selection states
  final RxnInt candidateId = RxnInt();
  final RxnInt stateId = RxnInt();
  final RxnInt districtId = RxnInt();

  // Lookup data lists
  final RxList<KycState> states = <KycState>[].obs;
  final RxList<KycDistrict> districts = <KycDistrict>[].obs;

  // Upload slots
  final RxMap<String, UploadedKycFile?> uploads = <String, UploadedKycFile?>{
    'identity': null,
    'resume': null,
    'photo': null,
  }.obs;

  // General Loading & Status
  final RxBool isLoading = false.obs;
  final RxnString errorMsg = RxnString();
  final RxString kycStatus = 'pending'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCandidateId();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    localityCtrl.dispose();
    pincodeCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }

  Future<void> loadCandidateId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('candidate_id');
      candidateId.value = id;
      if (id != null) {
        await fetchKycData(id);
      }
    } catch (e) {
      errorMsg.value = 'Failed to load user ID';
    }
  }

  Future<void> fetchKycData(int id) async {
    try {
      isLoading.value = true;
      errorMsg.value = null;

      final result = await repository.getKycData(id);
      result.fold(
        (failure) {
          errorMsg.value = failure.message;
        },
        (data) {
          states.assignAll(data.states);
          final candidate = data.candidate;

          nameCtrl.text = candidate.fullName;
          phoneCtrl.text = candidate.phone;
          emailCtrl.text = candidate.email;
          localityCtrl.text = candidate.locality;
          pincodeCtrl.text = candidate.pincode;
          addressCtrl.text = candidate.address;

          stateId.value = candidate.stateId;
          districtId.value = candidate.districtId;

          // Resolve names
          if (candidate.stateId != null) {
            final activeState = states.firstWhereOrNull(
              (s) => s.id == candidate.stateId,
            );
            if (activeState != null) {
              stateCtrl.text = activeState.name;
              districts.assignAll(activeState.districts);
              if (candidate.districtId != null) {
                final activeDistrict = districts.firstWhereOrNull(
                  (d) => d.id == candidate.districtId,
                );
                if (activeDistrict != null) {
                  districtCtrl.text = activeDistrict.name;
                }
              }
            }
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onStateSelected(KycState state) {
    stateId.value = state.id;
    stateCtrl.text = state.name;

    // Clear district selection
    districtId.value = null;
    districtCtrl.clear();

    // Populate districts
    districts.assignAll(state.districts);
  }

  void onDistrictSelected(KycDistrict district) {
    districtId.value = district.id;
    districtCtrl.text = district.name;
  }

  // ── Document Operations ──────────────────────

  Future<void> pickImage(String slotId, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null) return;

      uploads[slotId] = UploadedKycFile(
        name: picked.name,
        path: picked.path,
        isImage: true,
      );
    } catch (e) {
      errorMsg.value = 'Failed to pick image';
    }
  }

  Future<void> pickFile(String slotId) async {
    try {
      final List<String> exts = slotId == 'resume'
          ? ['pdf', 'doc', 'docx']
          : ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: exts,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;

      uploads[slotId] = UploadedKycFile(
        name: file.name,
        path: file.path ?? '',
        isImage: [
          'jpg',
          'jpeg',
          'png',
        ].contains(file.extension?.toLowerCase() ?? ''),
        size: file.size,
      );
    } catch (e) {
      errorMsg.value = 'Failed to pick document file';
    }
  }

  void removeUpload(String slotId) {
    uploads[slotId] = null;
  }

  // ── Validation & Submission ──────────────────

  String? validateFields() {
    if (nameCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        stateCtrl.text.trim().isEmpty ||
        districtCtrl.text.trim().isEmpty ||
        localityCtrl.text.trim().isEmpty ||
        pincodeCtrl.text.trim().isEmpty ||
        addressCtrl.text.trim().isEmpty) {
      return 'kyc_snack_missing_fields';
    }

    final phoneDigits = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length != 10) {
      return 'kyc_snack_invalid_phone';
    }

    final pinDigits = pincodeCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (pinDigits.length != 6) {
      return 'kyc_snack_invalid_pin';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(emailCtrl.text.trim())) {
      return 'kyc_snack_invalid_email';
    }

    final missing = uploads.entries
        .where((e) => e.value == null)
        .map((e) => e.key)
        .toList();
    if (missing.isNotEmpty) {
      return 'kyc_snack_missing_docs';
    }

    return null;
  }

  Future<bool> updateKyc() async {
    final validationError = validateFields();
    if (validationError != null) {
      errorMsg.value = validationError;
      return false;
    }

    try {
      isLoading.value = true;
      errorMsg.value = null;

      final prefs = await SharedPreferences.getInstance();
      final activeCandidateId =
          candidateId.value ?? prefs.getInt('candidate_id');
      final activeStateId = stateId.value ?? prefs.getInt('selected_state_id');

      if (activeCandidateId == null) {
        errorMsg.value = 'kyc_snack_no_candidate';
        return false;
      }

      final result = await repository.updateKyc(
        id: activeCandidateId,
        fullName: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        stateId: activeStateId ?? 0,
        districtId: districtId.value ?? 0,
        locality: localityCtrl.text.trim(),
        pincode: pincodeCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        idProofPath: uploads['identity']?.path,
        resumePath: uploads['resume']?.path,
        profilePhotoPath: uploads['photo']?.path,
      );

      return result.fold((failure) {
        errorMsg.value = failure.message;
        return false;
      }, (_) => true);
    } catch (e) {
      errorMsg.value = 'Failed to submit updates. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
