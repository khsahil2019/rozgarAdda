import 'package:get/get.dart';
import '../../domain/entities/available_job_entity.dart';
import '../../domain/entities/job_category.dart';
import '../../domain/entities/job_role_entity.dart';
import '../../domain/repository/jobs_repository.dart';

class JobsController extends GetxController {
  final JobsRepository repository;

  JobsController({required this.repository});

  // ── Categories ──────────────────────────────────────────────────────────────
  final RxList<JobCategory> categories = <JobCategory>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxnString categoriesError = RxnString();

  final Rxn<JobCategory> selectedCategory = Rxn<JobCategory>();

  // ── Job Roles ───────────────────────────────────────────────────────────────
  final RxList<JobRoleEntity> jobRoles = <JobRoleEntity>[].obs;
  final RxBool isLoadingJobRoles = false.obs;
  final RxnString jobRolesError = RxnString();

  // ── Available Jobs ──────────────────────────────────────────────────────────
  final Rxn<JobRoleEntity> selectedRole = Rxn<JobRoleEntity>();
  final RxList<AvailableJob> availableJobs = <AvailableJob>[].obs;
  final RxBool isLoadingAvailableJobs = false.obs;
  final RxnString availableJobsError = RxnString();

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
    availableJobs.clear();
    selectedRole.value = null;
    await fetchJobRoles(category.id);
  }

  // ── Available Jobs ──────────────────────────────────────────────────────────

  Future<void> fetchAvailableJobs(int roleId) async {
    try {
      isLoadingAvailableJobs.value = true;
      availableJobsError.value = null;

      final result = await repository.getAvailableJobs(roleId);
      result.fold(
        (failure) {
          availableJobsError.value = failure.message;
          availableJobs.clear();
        },
        (items) {
          availableJobs.assignAll(items);
        },
      );
    } finally {
      isLoadingAvailableJobs.value = false;
    }
  }

  void selectRole(JobRoleEntity role) {
    selectedRole.value = role;
    availableJobs.clear();
    fetchAvailableJobs(role.id);
  }
}
