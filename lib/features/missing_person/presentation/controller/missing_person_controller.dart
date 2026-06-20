import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/missing_person.dart';
import '../../domain/repository/missing_person_repository.dart';

class MissingPersonController extends GetxController {
  final MissingPersonRepository repository;

  MissingPersonController({required this.repository});

  // Feed states
  final RxList<MissingPerson> missingPersons = <MissingPerson>[].obs;
  final RxList<MissingPerson> filteredPersons = <MissingPerson>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter and search states
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = 'All'.obs;
  final RxString selectedState = 'All'.obs;
  final RxList<String> availableStates = <String>['All'].obs;

  // Form Fields & Controllers (Post Missing Person)
  final nameCtrl = TextEditingController();
  final relationInfoCtrl = TextEditingController(); // S/O, W/O, D/O, C/O info
  final stateCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final localityCtrl = TextEditingController();
  final villageCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final heightFromCtrl = TextEditingController();
  final heightToCtrl = TextEditingController();
  final mentalStatusCtrl = TextEditingController();
  final probableReasonCtrl = TextEditingController();
  final clothesWornCtrl = TextEditingController();
  final identityMarkCtrl = TextEditingController();

  // Complainant/Reporter details
  final complaintNameCtrl = TextEditingController();
  final complaintMobileCtrl = TextEditingController();
  final complaintReasonCtrl = TextEditingController();
  final complaintIdentityMarkCtrl = TextEditingController();
  final relationTypeCtrl = TextEditingController(); // e.g., Father, Mother
  final relativeAddressCtrl = TextEditingController();

  // FIR & Police Details
  final firNumberCtrl = TextEditingController();
  final policeStationNoCtrl = TextEditingController();
  final subInspectorCtrl = TextEditingController();
  final shoNoCtrl = TextEditingController();

  // Observable pickers & selectors
  final RxString postGender = 'Male'.obs;
  final Rxn<DateTime> postMissingDatetime = Rxn<DateTime>();
  final RxString postImage1Path = ''.obs;
  final RxString postImage2Path = ''.obs;
  final RxString postFirCopyPath = ''.obs;

  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMissingPersons();
    
    // Auto-apply filters when any of these change
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedGender, (_) => _applyFilters());
    ever(selectedState, (_) => _applyFilters());
  }

  @override
  void onClose() {
    // Dispose form controllers
    nameCtrl.dispose();
    relationInfoCtrl.dispose();
    stateCtrl.dispose();
    districtCtrl.dispose();
    localityCtrl.dispose();
    villageCtrl.dispose();
    pincodeCtrl.dispose();
    mobileCtrl.dispose();
    ageCtrl.dispose();
    heightFromCtrl.dispose();
    heightToCtrl.dispose();
    mentalStatusCtrl.dispose();
    probableReasonCtrl.dispose();
    clothesWornCtrl.dispose();
    identityMarkCtrl.dispose();
    
    complaintNameCtrl.dispose();
    complaintMobileCtrl.dispose();
    complaintReasonCtrl.dispose();
    complaintIdentityMarkCtrl.dispose();
    relationTypeCtrl.dispose();
    relativeAddressCtrl.dispose();

    firNumberCtrl.dispose();
    policeStationNoCtrl.dispose();
    subInspectorCtrl.dispose();
    shoNoCtrl.dispose();

    super.onClose();
  }

  Future<void> fetchMissingPersons() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await repository.getMissingPersons();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
      },
      (list) {
        missingPersons.assignAll(list);
        
        // Extract unique states for state filtering dropdown/sheet
        final states = list
            .map((e) => e.state.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();
        states.sort();
        availableStates.assignAll(['All', ...states]);

        _applyFilters();
      },
    );

    isLoading.value = false;
  }

  void _applyFilters() {
    var list = List<MissingPerson>.from(missingPersons);

    // Filter by search query (name, district, state, village, pincode)
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((person) {
        return person.name.toLowerCase().contains(query) ||
            person.district.toLowerCase().contains(query) ||
            person.state.toLowerCase().contains(query) ||
            person.village.toLowerCase().contains(query) ||
            person.pincode.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by gender
    if (selectedGender.value != 'All') {
      list = list.where((person) {
        return person.gender.toLowerCase() == selectedGender.value.toLowerCase();
      }).toList();
    }

    // Filter by state
    if (selectedState.value != 'All') {
      list = list.where((person) {
        return person.state.trim().toLowerCase() == selectedState.value.trim().toLowerCase();
      }).toList();
    }

    filteredPersons.assignAll(list);
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedGender.value = 'All';
    selectedState.value = 'All';
  }

  // ── Date and File Picking ──────────────────────────────────────────────────

  Future<void> pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: postMissingDatetime.value ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
    );

    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(postMissingDatetime.value ?? now),
      );

      if (pickedTime != null) {
        postMissingDatetime.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  Future<void> pickImage(int imageIndex, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked == null) return;

      if (imageIndex == 1) {
        postImage1Path.value = picked.path;
      } else {
        postImage2Path.value = picked.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> pickFirCopy() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        postFirCopyPath.value = result.files.single.path!;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file');
    }
  }

  // ── Validation & Submission ────────────────────────────────────────────────

  String? _validatePostFields() {
    if (nameCtrl.text.trim().isEmpty) return 'Missing person name is required';
    if (stateCtrl.text.trim().isEmpty) return 'State is required';
    if (districtCtrl.text.trim().isEmpty) return 'District is required';
    if (mobileCtrl.text.trim().isEmpty) return 'Mobile number is required';
    if (ageCtrl.text.trim().isEmpty) return 'Age is required';
    if (postMissingDatetime.value == null) return 'Missing date and time is required';
    if (complaintNameCtrl.text.trim().isEmpty) return 'Complainant name is required';
    if (complaintMobileCtrl.text.trim().isEmpty) return 'Complainant mobile is required';
    if (postImage1Path.value.isEmpty && postImage2Path.value.isEmpty) {
      return 'At least one photo of the missing person must be uploaded';
    }
    return null;
  }

  Future<bool> submitMissingPersonForm() async {
    final validationError = _validatePostFields();
    if (validationError != null) {
      Get.snackbar(
        'Validation Warning',
        validationError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isSubmitting.value = true;

      // Prepare form fields text values
      final Map<String, String> fields = {
        'name': nameCtrl.text.trim(),
        'relation_info': relationInfoCtrl.text.trim(),
        'state': stateCtrl.text.trim(),
        'district': districtCtrl.text.trim(),
        'locality': localityCtrl.text.trim(),
        'village': villageCtrl.text.trim(),
        'pincode': pincodeCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'reason': probableReasonCtrl.text.trim(),
        'height_from': heightFromCtrl.text.trim(),
        'height_to': heightToCtrl.text.trim(),
        'mental_status': mentalStatusCtrl.text.trim(),
        'missing_datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(postMissingDatetime.value!),
        'age': ageCtrl.text.trim(),
        'gender': postGender.value,
        'clothes': clothesWornCtrl.text.trim(),
        'identity_mark': identityMarkCtrl.text.trim(),
        'complaint_name': complaintNameCtrl.text.trim(),
        'complaint_mobile': complaintMobileCtrl.text.trim(),
        'complaint_reason': complaintReasonCtrl.text.trim(),
        'complaint_identity_mark': complaintIdentityMarkCtrl.text.trim(),
        'relation_type': relationTypeCtrl.text.trim(),
        'relative_address': relativeAddressCtrl.text.trim(),
        'fir_number': firNumberCtrl.text.trim(),
        'police_station_no': policeStationNoCtrl.text.trim(),
        'sub_inspector': subInspectorCtrl.text.trim(),
        'sho_no': shoNoCtrl.text.trim(),
      };

      // Prepare file paths
      final Map<String, String> files = {
        if (postImage1Path.value.isNotEmpty) 'image1': postImage1Path.value,
        if (postImage2Path.value.isNotEmpty) 'image2': postImage2Path.value,
        if (postFirCopyPath.value.isNotEmpty) 'fir_copy': postFirCopyPath.value,
      };

      final result = await repository.addMissingPerson(fields: fields, files: files);

      return result.fold(
        (failure) {
          Get.snackbar(
            'Error Submitting Details',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          return false;
        },
        (successMsg) {
          Get.snackbar(
            'Success',
            successMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          
          _clearFormFields();
          fetchMissingPersons(); // Reload the missing list
          return true;
        },
      );
    } catch (e) {
      Get.snackbar(
        'Submission Error',
        'Something went wrong. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _clearFormFields() {
    nameCtrl.clear();
    relationInfoCtrl.clear();
    stateCtrl.clear();
    districtCtrl.clear();
    localityCtrl.clear();
    villageCtrl.clear();
    pincodeCtrl.clear();
    mobileCtrl.clear();
    ageCtrl.clear();
    heightFromCtrl.clear();
    heightToCtrl.clear();
    mentalStatusCtrl.clear();
    probableReasonCtrl.clear();
    clothesWornCtrl.clear();
    identityMarkCtrl.clear();
    
    complaintNameCtrl.clear();
    complaintMobileCtrl.clear();
    complaintReasonCtrl.clear();
    complaintIdentityMarkCtrl.clear();
    relationTypeCtrl.clear();
    relativeAddressCtrl.clear();

    firNumberCtrl.clear();
    policeStationNoCtrl.clear();
    subInspectorCtrl.clear();
    shoNoCtrl.clear();

    postGender.value = 'Male';
    postMissingDatetime.value = null;
    postImage1Path.value = '';
    postImage2Path.value = '';
    postFirCopyPath.value = '';
  }
}
