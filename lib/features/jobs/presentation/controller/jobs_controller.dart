import 'package:get/get.dart';
import '../../domain/entities/job_category.dart';
import '../../domain/entities/job_role_entity.dart';
import '../../domain/repository/jobs_repository.dart';

class JobsController extends GetxController {
  final JobsRepository repository;

  JobsController({required this.repository});

  final RxList<JobCategory> categories = <JobCategory>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxnString categoriesError = RxnString();

  final Rxn<JobCategory> selectedCategory = Rxn<JobCategory>();
  final RxList<JobRoleEntity> jobRoles = <JobRoleEntity>[].obs;
  final RxBool isLoadingJobRoles = false.obs;
  final RxnString jobRolesError = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      categoriesError.value = null;

      final result = await repository.getCategories();
      result.fold(
        (failure) {
          categoriesError.value = failure.message;
          categories.clear();
        },
        (items) {
          categories.assignAll(items);
        },
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchJobRoles(int categoryId) async {
    try {
      isLoadingJobRoles.value = true;
      jobRolesError.value = null;

      final result = await repository.getJobRoles(categoryId);
      result.fold(
        (failure) {
          jobRolesError.value = failure.message;
          jobRoles.clear();
        },
        (items) {
          jobRoles.assignAll(items);
        },
      );
    } finally {
      isLoadingJobRoles.value = false;
    }
  }

  Future<void> selectCategory(JobCategory category) async {
    selectedCategory.value = category;
    jobRoles.clear();
    await fetchJobRoles(category.id);
  }
}
