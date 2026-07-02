import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';
import 'package:rojgar/features/auth/domain/repository/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository authRepository;

  RegisterController({required this.authRepository});

  // ── Form text controllers ──────────────────────────────────────────────────
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Six individual controllers for OTP digits.
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // ── Reactive values ────────────────────────────────────────────────────────
  final RxString fullName = ''.obs;
  final RxString phone = ''.obs;
  final RxString email = ''.obs;
  final RxString locality = ''.obs;
  final RxString pincode = ''.obs;
  final RxString address = ''.obs;
  final RxString username = ''.obs;
  final RxString password = ''.obs;

  // ── Dropdown data ──────────────────────────────────────────────────────────
  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxnInt selectedStateId = RxnInt();
  final RxnInt selectedDistrictId = RxnInt();

  // ── Loading flags ──────────────────────────────────────────────────────────
  final RxBool isStatesLoading = false.obs;
  final RxBool isDistrictsLoading = false.obs;
  final RxBool isLoading = false.obs;

  // ── OTP state ──────────────────────────────────────────────────────────────
  /// True after a successful send-OTP call — shows the OTP input row.
  final RxBool isOtpSent = false.obs;

  /// True after the server confirms the OTP is correct.
  final RxBool isPhoneVerified = false.obs;

  /// Loading spinner for Send OTP button.
  final RxBool isSendingOtp = false.obs;

  /// Loading spinner for Verify OTP button.
  final RxBool isVerifyingOtp = false.obs;

  /// Countdown (seconds) until resend is allowed. 0 = allowed.
  final RxInt resendCountdown = 0.obs;

  Timer? _resendTimer;

  // ── Terms ──────────────────────────────────────────────────────────────────
  final RxBool acceptedTerms = false.obs;

  // ── File Upload ───────────────────────────────────────────────────────────
  final RxnString identityProofPath = RxnString();

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _addListeners();
    fetchStates();
  }

  void _addListeners() {
    fullNameController.addListener(
      () => fullName.value = fullNameController.text,
    );
    phoneController.addListener(() => phone.value = phoneController.text);
    emailController.addListener(() => email.value = emailController.text);
    localityController.addListener(
      () => locality.value = localityController.text,
    );
    pincodeController.addListener(() => pincode.value = pincodeController.text);
    addressController.addListener(() => address.value = addressController.text);
    usernameController.addListener(
      () => username.value = usernameController.text,
    );
    passwordController.addListener(
      () => password.value = passwordController.text,
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    localityController.dispose();
    pincodeController.dispose();
    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    _resendTimer?.cancel();
    super.onClose();
  }

  // ── OTP helpers ────────────────────────────────────────────────────────────

  /// The concatenated 6-digit OTP value from the individual controllers.
  String get otpValue => otpControllers.map((c) => c.text.trim()).join();

  /// Starts a 60-second resend cooldown.
  void _startResendTimer() {
    resendCountdown.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendCountdown.value <= 0) {
        t.cancel();
      } else {
        resendCountdown.value--;
      }
    });
  }

  /// Sends OTP to the entered phone number.
  ///
  /// Returns the error message string on failure, null on success.
  Future<String?> sendOtp() async {
    final phoneNum = phone.value.trim();
    if (phoneNum.isEmpty || phoneNum.length < 10) {
      return 'Please enter a valid 10-digit phone number.';
    }

    isSendingOtp.value = true;
    try {
      final either = await authRepository.sendOtp(phoneNum);
      return either.fold((failure) => failure.message, (_) {
        isOtpSent.value = true;
        isPhoneVerified.value = false;
        _clearOtpFields();
        _startResendTimer();
        return null; // success
      });
    } finally {
      isSendingOtp.value = false;
    }
  }

  /// Verifies the OTP entered by the user.
  ///
  /// Returns the error message string on failure, null on success.
  Future<String?> verifyOtp() async {
    final otp = otpValue;
    if (otp.length < 6) {
      return 'Please enter the complete 6-digit OTP.';
    }

    isVerifyingOtp.value = true;
    try {
      final either = await authRepository.verifyOtp(phone.value.trim(), otp);
      return either.fold((failure) => failure.message, (_) {
        isPhoneVerified.value = true;
        _resendTimer?.cancel();
        resendCountdown.value = 0;
        return null; // success
      });
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  void _clearOtpFields() {
    for (final c in otpControllers) {
      c.clear();
    }
  }

  void resetPhoneVerification() {
    isPhoneVerified.value = false;
    isOtpSent.value = false;
    _clearOtpFields();
    _resendTimer?.cancel();
    resendCountdown.value = 0;
  }

  // ── Dropdowns ──────────────────────────────────────────────────────────────
  Future<void> fetchStates() async {
    isStatesLoading.value = true;
    try {
      final either = await authRepository.getStates();
      either.fold((_) {}, (res) => states.assignAll(res));
    } catch (_) {
    } finally {
      isStatesLoading.value = false;
    }
  }

  Future<void> fetchDistricts(int stateId) async {
    isDistrictsLoading.value = true;
    selectedDistrictId.value = null;
    districts.clear();
    try {
      final either = await authRepository.getDistricts(stateId);
      either.fold((_) {}, (res) => districts.assignAll(res));
    } catch (_) {
    } finally {
      isDistrictsLoading.value = false;
    }
  }

  void selectState(int? stateId) {
    if (stateId == null) return;
    selectedStateId.value = stateId;
    fetchDistricts(stateId);
  }

  void selectDistrict(int? districtId) {
    selectedDistrictId.value = districtId;
  }

  void toggleTermsAcceptance() {
    acceptedTerms.value = !acceptedTerms.value;
  }

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

  // ── Form gate ──────────────────────────────────────────────────────────────
  bool get isRegistrationEnabled =>
      fullName.value.trim().isNotEmpty &&
      phone.value.trim().isNotEmpty &&
      isPhoneVerified.value && // phone must be OTP-verified
      email.value.trim().isNotEmpty &&
      locality.value.trim().isNotEmpty &&
      pincode.value.trim().isNotEmpty &&
      address.value.trim().isNotEmpty &&
      username.value.trim().isNotEmpty &&
      password.value.isNotEmpty &&
      selectedStateId.value != null &&
      selectedDistrictId.value != null &&
      identityProofPath.value != null &&
      acceptedTerms.value &&
      !isLoading.value;

  // ── Register ───────────────────────────────────────────────────────────────
  Future<AuthResponse> register() async {
    isLoading.value = true;
    try {
      final either = await authRepository.register(
        fullName: fullName.value.trim(),
        phone: phone.value.trim(),
        email: email.value.trim(),
        username: username.value.trim(),
        password: password.value,
        state: selectedStateId.value.toString(),
        district: selectedDistrictId.value.toString(),
        locality: locality.value.trim(),
        pincode: pincode.value.trim(),
        address: address.value.trim(),
        identityProofPath: identityProofPath.value,
        termsAccepted: acceptedTerms.value ? '1' : '0',
        otp: otpValue,
      );

      return either.fold((failure) => throw failure, (result) {
        AppController.to.login(result);
        return result;
      });
    } finally {
      isLoading.value = false;
    }
  }
}
