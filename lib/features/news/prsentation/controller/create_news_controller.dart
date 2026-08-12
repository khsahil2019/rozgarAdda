import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/news_category.dart';
import '../../domain/entities/news_state.dart';
import '../../domain/repository/news_repository.dart';
import 'news_controller.dart';

class CreateNewsController extends GetxController {
  final NewsRepository repository;

  CreateNewsController({required this.repository});

  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final RxList<NewsCategory> categories = <NewsCategory>[].obs;
  final RxList<NewsState> states = <NewsState>[].obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedStateId = RxnInt();
  final RxString imagePath = ''.obs;

  final RxBool isLoadingOptions = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOptions();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }

  /// Reuses the feed's already-loaded filters when available, otherwise fetches.
  Future<void> loadOptions() async {
    isLoadingOptions.value = true;
    errorMessage.value = '';

    final feed = Get.isRegistered<NewsController>()
        ? Get.find<NewsController>()
        : null;

    if (feed != null && feed.categories.isNotEmpty && feed.states.isNotEmpty) {
      categories.assignAll(feed.categories);
      states.assignAll(feed.states);
      selectedCategoryId.value ??= feed.selectedCategoryId.value;
      selectedStateId.value ??= feed.selectedStateId.value;
      isLoadingOptions.value = false;
      return;
    }

    final categoriesFuture = repository.getCategories();
    final statesFuture = repository.getStates();

    (await categoriesFuture).fold(
      (failure) => errorMessage.value = failure.message,
      (list) => categories.assignAll(list),
    );
    (await statesFuture).fold(
      (failure) => errorMessage.value = errorMessage.value.isEmpty
          ? failure.message
          : errorMessage.value,
      (list) => states.assignAll(list),
    );

    selectedCategoryId.value ??= categories.isNotEmpty
        ? categories.first.id
        : null;
    selectedStateId.value ??= states.isNotEmpty ? states.first.id : null;
    isLoadingOptions.value = false;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked != null) imagePath.value = picked.path;
    } catch (_) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  void clearImage() => imagePath.value = '';

  String? validate() {
    if (selectedCategoryId.value == null) return 'news_form_error_category';
    if (selectedStateId.value == null) return 'news_form_error_state';
    if (titleCtrl.text.trim().isEmpty) return 'news_form_error_title';
    if (descriptionCtrl.text.trim().isEmpty) {
      return 'news_form_error_description';
    }
    if (imagePath.value.isEmpty) return 'news_form_error_image';
    return null;
  }

  Future<String?> submit() async {
    isSubmitting.value = true;
    final result = await repository.createNews(
      categoryId: selectedCategoryId.value!,
      stateId: selectedStateId.value!,
      title: titleCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      imagePath: imagePath.value.isEmpty ? null : imagePath.value,
    );
    isSubmitting.value = false;

    return result.fold((failure) => failure.message, (_) {
      _reset();
      if (Get.isRegistered<NewsController>()) {
        Get.find<NewsController>().fetchNews();
      }
      return null;
    });
  }

  void _reset() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    imagePath.value = '';
  }
}
