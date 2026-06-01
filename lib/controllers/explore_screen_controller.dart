import 'package:get/get.dart';
import 'package:rojgar/models/explore_model.dart';
import 'package:rojgar/models/job_role_model.dart';
import 'package:rojgar/services/category_api_service.dart';
import 'package:rojgar/services/job_role_api_service.dart';
import 'package:rojgar/services/sub_category_api_service.dart';

class DashboardController extends GetxController {
  final CategoryApiService _categoryApiService = CategoryApiService();
  final JobRoleApiService _jobRoleApiService = JobRoleApiService();
  final SubCategoryApiService _subCategoryApiService = SubCategoryApiService();

  final isLoading = false.obs;
  final error = RxnString();
  final categories = <DashboardCategory>[].obs;
  final selectedCategory = Rxn<DashboardCategory>();
  final isSubCategoriesLoading = false.obs;
  final subCategoriesError = RxnString();
  final subCategories = <DashboardSubCategory>[].obs;
  final selectedSubCategory = Rxn<DashboardSubCategory>();
  final isJobRolesLoading = false.obs;
  final jobRolesError = RxnString();
  final jobRoles = <JobRole>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      error.value = null;

      final items = await _categoryApiService.fetchCategories();
      categories
        ..clear()
        ..addAll(items);

      if (items.isNotEmpty) {
        await selectCategory(items.first);
      } else {
        selectedCategory.value = null;
        selectedSubCategory.value = null;
        subCategories.clear();
        jobRoles.clear();
      }
    } catch (errorObject) {
      error.value = errorObject is CategoryApiException
          ? errorObject.message
          : 'Unable to load categories. Please check your connection.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCategory(DashboardCategory category) async {
    selectedCategory.value = category;
    selectedSubCategory.value = null;
    subCategories.clear();
    jobRoles.clear();
    await fetchSubCategories(category.id);
  }

  Future<void> selectSubCategory(DashboardSubCategory subCategory) async {
    selectedSubCategory.value = subCategory;
    await fetchJobRoles(subCategory.id);
  }

  Future<void> fetchSubCategories(int categoryId) async {
    try {
      isSubCategoriesLoading.value = true;
      subCategoriesError.value = null;
      selectedSubCategory.value = null;
      jobRoles.clear();

      final items = await _subCategoryApiService.fetchSubCategories(categoryId);
      subCategories.value = [...items];

      if (items.isNotEmpty) {
        await selectSubCategory(items.first);
      }
    } catch (errorObject) {
      subCategoriesError.value = errorObject is SubCategoryApiException
          ? errorObject.message
          : 'Unable to load sub-categories. Please check your connection.';
      subCategories.value = [];
      selectedSubCategory.value = null;
      jobRoles.value = [];
    } finally {
      isSubCategoriesLoading.value = false;
    }
  }

  Future<void> fetchJobRoles(int subCategoryId) async {
    try {
      isJobRolesLoading.value = true;
      jobRolesError.value = null;

      final items = await _jobRoleApiService.fetchJobRoles(subCategoryId);
      jobRoles.value = [...items];
    } catch (errorObject) {
      jobRolesError.value = errorObject is JobRoleApiException
          ? errorObject.message
          : 'Unable to load job roles. Please check your connection.';
      jobRoles.value = [];
    } finally {
      isJobRolesLoading.value = false;
    }
  }
}
