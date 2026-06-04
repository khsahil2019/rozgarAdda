import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/sell_product_entities.dart';
import '../../domain/repository/sell_product_repository.dart';

class SellProductController extends GetxController {
  final SellProductRepository repository;

  SellProductController({required this.repository});

  // State Lists
  final RxList<SellProductCategory> categories = <SellProductCategory>[].obs;
  final RxList<SellProductSubCategory> subCategories = <SellProductSubCategory>[].obs;

  // Selected indices
  final RxnInt selectedCategoryIndex = RxnInt();
  final RxnInt selectedSubCategoryIndex = RxnInt();

  // Loading States
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingSubCategories = false.obs;
  final RxBool isSaving = false.obs;

  // Errors
  final RxnString categoriesError = RxnString();
  final RxnString subCategoriesError = RxnString();
  final RxnString savingError = RxnString();

  // Form Fields
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final featuresCtrl = TextEditingController();
  final priceCtrl = TextEditingController(text: '0.00');
  final discountCtrl = TextEditingController(text: '0');
  final capacityCtrl = TextEditingController();
  final warrantyCtrl = TextEditingController();
  final RxBool isActive = true.obs;

  // Images state
  final Rxn<XFile> mainImage = Rxn<XFile>();
  final RxList<XFile> galleryImages = <XFile>[].obs;

  // Reactive total cost
  final RxDouble totalCostObx = 0.0.obs;

  // Dynamic calculated total cost
  double get totalCost {
    final price = double.tryParse(priceCtrl.text) ?? 0.0;
    final discount = double.tryParse(discountCtrl.text) ?? 0.0;
    return price - (price * discount / 100.0);
  }

  void _updateTotalCost() {
    totalCostObx.value = totalCost;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    priceCtrl.addListener(_updateTotalCost);
    discountCtrl.addListener(_updateTotalCost);
    _updateTotalCost();
  }

  @override
  void onClose() {
    priceCtrl.removeListener(_updateTotalCost);
    discountCtrl.removeListener(_updateTotalCost);
    titleCtrl.dispose();
    descCtrl.dispose();
    featuresCtrl.dispose();
    priceCtrl.dispose();
    discountCtrl.dispose();
    capacityCtrl.dispose();
    warrantyCtrl.dispose();
    super.onClose();
  }

  // Fetch Categories
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      categoriesError.value = null;
      selectedCategoryIndex.value = null;
      selectedSubCategoryIndex.value = null;
      subCategories.clear();

      final lang = Get.locale?.languageCode ?? 'en';
      final result = await repository.getCategories(lang);

      result.fold(
        (failure) => categoriesError.value = failure.message,
        (data) => categories.assignAll(data),
      );
    } catch (e) {
      categoriesError.value = 'Failed to load categories';
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Fetch Subcategories
  Future<void> fetchSubCategories(int categoryId) async {
    try {
      isLoadingSubCategories.value = true;
      subCategoriesError.value = null;
      selectedSubCategoryIndex.value = null;
      subCategories.clear();

      final lang = Get.locale?.languageCode ?? 'en';
      final result = await repository.getSubCategories(categoryId, lang);

      result.fold(
        (failure) => subCategoriesError.value = failure.message,
        (data) => subCategories.assignAll(data),
      );
    } catch (e) {
      subCategoriesError.value = 'Failed to load sub-categories';
    } finally {
      isLoadingSubCategories.value = false;
    }
  }

  // Image Picking
  Future<void> pickMainImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        mainImage.value = picked;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick main image');
    }
  }

  Future<void> pickGalleryImages() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(limit: 5);
      if (picked.isNotEmpty) {
        galleryImages.assignAll(picked.take(5));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick gallery images');
    }
  }

  void removeGalleryImage(int index) {
    galleryImages.removeAt(index);
  }

  // Set selected category & load subcategories
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    final category = categories[index];
    fetchSubCategories(category.id);
  }

  // Set selected subcategory
  void selectSubCategory(int index) {
    selectedSubCategoryIndex.value = index;
  }

  // Reset form states
  void resetForm() {
    titleCtrl.clear();
    descCtrl.clear();
    featuresCtrl.clear();
    priceCtrl.text = '0.00';
    discountCtrl.text = '0';
    capacityCtrl.clear();
    warrantyCtrl.clear();
    isActive.value = true;
    mainImage.value = null;
    galleryImages.clear();
    savingError.value = null;
    _updateTotalCost();
  }

  // Save the product
  Future<bool> saveProduct() async {
    if (selectedCategoryIndex.value == null || selectedSubCategoryIndex.value == null) {
      savingError.value = 'Please select both Category and Sub Category';
      return false;
    }
    if (mainImage.value == null) {
      savingError.value = 'Please select a main product image.';
      return false;
    }

    try {
      isSaving.value = true;
      savingError.value = null;

      final category = categories[selectedCategoryIndex.value!];
      final subCategory = subCategories[selectedSubCategoryIndex.value!];

      final request = SellProductRequest(
        categoryId: category.id,
        subCategoryId: subCategory.id,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        price: double.tryParse(priceCtrl.text) ?? 0.0,
        discount: int.tryParse(discountCtrl.text) ?? 0,
        features: featuresCtrl.text.trim(),
        capacity: capacityCtrl.text.trim(),
        warranty: warrantyCtrl.text.trim(),
        isActive: isActive.value,
        mainImagePath: mainImage.value!.path,
        galleryImagePaths: galleryImages.map((e) => e.path).toList(),
      );

      final result = await repository.saveProduct(request);

      return result.fold(
        (failure) {
          savingError.value = failure.message;
          return false;
        },
        (message) {
          resetForm();
          return true;
        },
      );
    } catch (e) {
      savingError.value = 'Something went wrong while saving the product.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
