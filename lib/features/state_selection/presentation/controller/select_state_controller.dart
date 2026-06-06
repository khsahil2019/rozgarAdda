import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import '../../domain/entities/state_entity.dart';
import '../../domain/repository/state_repository.dart';

class SelectStateController extends GetxController {
  final StateRepository _repository;

  SelectStateController(this._repository);

  final rxStates = <StateEntity>[].obs;
  final rxIsLoading = false.obs;
  final rxError = RxnString();
  final rxSearchQuery = ''.obs;
  final rxSelectedStateId = RxnInt();

  List<StateEntity> get states => rxStates;
  bool get isLoading => rxIsLoading.value;
  String? get error => rxError.value;
  String get searchQuery => rxSearchQuery.value;
  int? get selectedStateId => rxSelectedStateId.value;

  @override
  void onInit() {
    super.onInit();
    fetchStates();
  }

  Future<void> fetchStates() async {
    rxIsLoading.value = true;
    rxError.value = null;

    final result = await _repository.getStatesImages();
    result.fold(
      (failure) {
        rxIsLoading.value = false;
        rxError.value = failure.message;
      },
      (data) {
        rxStates.assignAll(data);
        rxIsLoading.value = false;
        if (data.isNotEmpty) {
          final savedStateId = AppController.to.selectedStateId;
          if (savedStateId != null && data.any((s) => s.id == savedStateId)) {
            rxSelectedStateId.value = savedStateId;
          } else {
            rxSelectedStateId.value = data.first.id;
          }
        }
      },
    );
  }

  void selectState(int id) {
    rxSelectedStateId.value = id;
  }

  void updateSearchQuery(String query) {
    rxSearchQuery.value = query.trim();
  }

  List<StateEntity> get filteredStates {
    if (searchQuery.isEmpty) {
      return states;
    }
    final q = searchQuery.toLowerCase();
    return states.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.language.toLowerCase().contains(q);
    }).toList();
  }

  void saveSelection(int id, String name) {
    AppController.to.updateSelectedState(id, name);
  }
}
