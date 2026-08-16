import 'package:get/get.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../../auth/data/data_source/model/dropdown_item.dart';
import '../../domain/entities/available_job_entity.dart';
import '../../domain/entities/job_category.dart';
import '../../domain/entities/job_role_entity.dart';
import '../../domain/repository/jobs_repository.dart';

class JobsController extends GetxController {
  final JobsRepository repository;

  JobsController({required this.repository});

  // ── Location Filter Data ───────────────────────────────────────────────────
  final RxList<DropdownItem> states = <DropdownItem>[].obs;
  final RxList<DropdownItem> districts = <DropdownItem>[].obs;
  final RxList<DropdownItem> localities = <DropdownItem>[].obs;

  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingDistricts = false.obs;
  final RxBool isLoadingLocalities = false.obs;

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

  Future<void> fetchAvailableJobs(
    int roleId, {
    int? stateId,
    int? districtId,
    int? localityId,
  }) async {
    try {
      isLoadingAvailableJobs.value = true;
      availableJobsError.value = null;

      final result = await repository.getAvailableJobs(
        roleId,
        stateId: stateId,
        districtId: districtId,
        localityId: localityId,
      );
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

  // ── Location Fetching ──────────────────────────────────────────────────────

  Future<void> fetchStates() async {
    try {
      isLoadingStates.value = true;
      final result = await repository.getStates();
      result.fold(
        (failure) => states.clear(),
        (items) => states.assignAll(items),
      );
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> fetchDistricts(int stateId) async {
    try {
      isLoadingDistricts.value = true;
      districts.clear();
      localities.clear();
      final result = await repository.getDistricts(stateId);
      result.fold(
        (failure) => districts.clear(),
        (items) => districts.assignAll(items),
      );
    } finally {
      isLoadingDistricts.value = false;
    }
  }

  Future<void> fetchLocalities(int districtId) async {
    try {
      isLoadingLocalities.value = true;
      localities.clear();
      final result = await repository.getLocalities(districtId);
      result.fold(
        (failure) => localities.clear(),
        (items) => localities.assignAll(items),
      );
    } finally {
      isLoadingLocalities.value = false;
    }
  }

  Future<Either<Failure, bool>> logCallAndChatApply({
    required int jobId,
    required String type,
    required String phone
  }) async {
    return await repository.logCallAndChatApply(jobId: jobId, type: type, phone: phone);
  }
}
