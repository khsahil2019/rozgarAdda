import 'package:get/get.dart';
import '../../domain/entities/missing_person.dart';
import '../../domain/repository/missing_person_repository.dart';

class MissingPersonController extends GetxController {
  final MissingPersonRepository repository;

  MissingPersonController({required this.repository});

  final RxList<MissingPerson> missingPersons = <MissingPerson>[].obs;
  final RxList<MissingPerson> filteredPersons = <MissingPerson>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter and search states
  final RxString searchQuery = ''.obs;
  final RxString selectedGender = 'All'.obs;
  final RxString selectedState = 'All'.obs;
  final RxList<String> availableStates = <String>['All'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMissingPersons();
    
    // Auto-apply filters when any of these change
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedGender, (_) => _applyFilters());
    ever(selectedState, (_) => _applyFilters());
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
}
