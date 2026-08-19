import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt currentNavIndex = 0.obs;
  final RxString selectedState = 'All India'.obs;
  final RxString userName = 'Candidate'.obs;
  final RxString userPhone = ''.obs;

  final TextEditingController searchController = TextEditingController();

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  void updateState(String newState) {
    selectedState.value = newState;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
