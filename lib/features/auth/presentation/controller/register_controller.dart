import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';
import 'package:rojgar/features/auth/domain/repository/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository authRepository;

  RegisterController({required this.authRepository});

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Reactive text fields values
  final RxString fullName = ''.obs;
  final RxString phone = ''.obs;
  final RxString email = ''.obs;
  final RxString locality = ''.obs;
  final RxString pincode = ''.obs;
  final RxString address = ''.obs;
  final RxString username = ''.obs;
  final RxString password = ''.obs;

  // Selection states
  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;

  final RxnInt selectedStateId = RxnInt();
  final RxnInt selectedDistrictId = RxnInt();

  // Loading flags
  final RxBool isStatesLoading = false.obs;
  final RxBool isDistrictsLoading = false.obs;
  final RxBool isLoading = false.obs;

  final RxBool acceptedTerms = false.obs;

  @override
  void onInit() {
    super.onInit();
    _addListeners();
    fetchStates();
  }

  void _addListeners() {
    fullNameController.addListener(() => fullName.value = fullNameController.text);
    phoneController.addListener(() => phone.value = phoneController.text);
    emailController.addListener(() => email.value = emailController.text);
    localityController.addListener(() => locality.value = localityController.text);
    pincodeController.addListener(() => pincode.value = pincodeController.text);
    addressController.addListener(() => address.value = addressController.text);
    usernameController.addListener(() => username.value = usernameController.text);
    passwordController.addListener(() => password.value = passwordController.text);
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
    super.onClose();
  }

  Future<void> fetchStates() async {
    isStatesLoading.value = true;
    try {
      final res = await authRepository.getStates();
      states.assignAll(res);
    } catch (_) {
      // fail silently or handle in UI
    } finally {
      isStatesLoading.value = false;
    }
  }

  Future<void> fetchDistricts(int stateId) async {
    isDistrictsLoading.value = true;
    selectedDistrictId.value = null;
    districts.clear();
    try {
      final res = await authRepository.getDistricts(stateId);
      districts.assignAll(res);
    } catch (_) {
      // fail silently or handle in UI
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

  bool get isRegistrationEnabled =>
      fullName.value.trim().isNotEmpty &&
      phone.value.trim().isNotEmpty &&
      email.value.trim().isNotEmpty &&
      locality.value.trim().isNotEmpty &&
      pincode.value.trim().isNotEmpty &&
      address.value.trim().isNotEmpty &&
      username.value.trim().isNotEmpty &&
      password.value.isNotEmpty &&
      selectedStateId.value != null &&
      selectedDistrictId.value != null &&
      acceptedTerms.value &&
      !isLoading.value;

  Future<AuthResponse> register() async {
    isLoading.value = true;
    try {
      final result = await authRepository.register(
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
      );

      // Log in globally in AppController
      AppController.to.login(result);

      return result;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
