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
  final subjectCtrl = TextEditingController();

  final RxList<NewsCategory> categories = <NewsCategory>[].obs;
  final RxList<NewsState> states = <NewsState>[].obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedStateId = RxnInt();
  final RxString imagePath = ''.obs;
  final RxString videoPath = ''.obs;

  final RxBool isPostTypeVideo = false.obs;
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
    subjectCtrl.dispose();
    super.onClose();
  }

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

  Future<void> pickVideo(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null) videoPath.value = picked.path;
    } catch (_) {
      Get.snackbar('Error', 'Failed to pick video file');
    }
  }

  void clearImage() => imagePath.value = '';
  void clearVideo() => videoPath.value = '';

  String? validate() {
    if (selectedCategoryId.value == null) return 'news_form_error_category';
    if (selectedStateId.value == null) return 'news_form_error_state';
    if (titleCtrl.text.trim().isEmpty) return 'news_form_error_title';

    if (isPostTypeVideo.value) {
      if (subjectCtrl.text.trim().isEmpty && descriptionCtrl.text.trim().isEmpty) {
        return 'Please enter video subject or description';
      }
      if (videoPath.value.isEmpty) return 'Please select a video file to upload';
    } else {
      if (descriptionCtrl.text.trim().isEmpty) return 'news_form_error_description';
      if (imagePath.value.isEmpty) return 'news_form_error_image';
    }
    return null;
  }

  Future<String?> submit() async {
    isSubmitting.value = true;

    if (isPostTypeVideo.value) {
      final subjectText = subjectCtrl.text.trim().isNotEmpty
          ? subjectCtrl.text.trim()
          : descriptionCtrl.text.trim();

      final result = await repository.createVideoNews(
        categoryId: selectedCategoryId.value!,
        stateId: selectedStateId.value!,
        title: titleCtrl.text.trim(),
        subject: subjectText,
        videoPath: videoPath.value,
      );
      isSubmitting.value = false;

      return result.fold((failure) => failure.message, (_) {
        _reset();
        if (Get.isRegistered<NewsController>()) {
          Get.find<NewsController>().fetchNews();
        }
        return null;
      });
    } else {
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
  }

  void _reset() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    subjectCtrl.clear();
    imagePath.value = '';
    videoPath.value = '';
  }
}
