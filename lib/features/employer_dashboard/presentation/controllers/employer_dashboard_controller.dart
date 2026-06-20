import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../../jobs/data/model/available_job_model.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';
import '../../data/models/mock_employer_database.dart';
import '../../domain/entities/job_application_entity.dart';

class EmployerDashboardController extends GetxController {
  final MockEmployerDatabase db = MockEmployerDatabase();

  final RxInt employerId = 0.obs;
  final RxList<AvailableJob> postedJobs = <AvailableJob>[].obs;
  final RxMap<int, List<JobApplication>> jobApplications =
      <int, List<JobApplication>>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final empId =
          prefs.getInt('employer_id') ?? 2001; // Fallback to seeded employer
      employerId.value = empId;
      final token = prefs.getString('employer_token');

      List<AvailableJob> jobs = [];

      if (token != null && token.isNotEmpty) {
        try {
          final res = await ApiService.get(
            ApiRoutes.employerJobs,
            accessToken: token,
          );
          if (res['status'] == true &&
              res['jobs']['data'] != null &&
              res['jobs']['data'].isNotEmpty) {
            final List<dynamic> jobsData = res['jobs']['data'] ?? [];
            jobs = jobsData
                .map<AvailableJob>(
                  (j) => AvailableJobModel.fromJson(
                    j as Map<String, dynamic>,
                  ).toEntity(),
                )
                .toList();
          } else {
            await db.init();
            jobs = await db.getEmployerJobs(empId);
          }
        } catch (e) {
          await db.init();
          jobs = await db.getEmployerJobs(empId);
        }
      } else {
        await db.init();
        jobs = await db.getEmployerJobs(empId);
      }

      // Sort jobs by createdAt descending
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      postedJobs.assignAll(jobs);

      // Load applications for each job
      for (final job in jobs) {
        final apps = await db.getJobApplications(job.id);
        jobApplications[job.id] = apps;
      }
    } finally {
      isLoading.value = false;
    }
  }

  int get totalApplications {
    int count = 0;
    jobApplications.forEach((_, list) {
      count += list.length;
    });
    return count;
  }

  int get totalViews {
    return postedJobs.fold(0, (sum, job) => sum + job.viewsCount);
  }

  Future<void> postNewJob(AvailableJob newJob) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('employer_token');

      if (token == null || token.isEmpty) {
        throw Failure('Authentication token not found. Please login again.');
      }

      final body = <String, dynamic>{
        'category_id': newJob.categoryId,
        'role_id': newJob.roleId,
        'title': newJob.title,
        'vacancy': newJob.vacancy,
        'job_type': newJob.jobType,
        'work_location_type': newJob.workLocationType,
        'pay_type': newJob.payType,
        'education_level': newJob.educationLevel,
        'english_level': newJob.englishLevel,
        'experience_level': newJob.experienceLevel,
        'plan_id': 1,
        'skills': newJob.skills,
        'languages': newJob.languages,
        'perks': newJob.perks,
        'shifts': newJob.shifts,
        'is_walkin': newJob.isWalkin ? 1 : 0,
        'contact_preference': newJob.contactPreference,
      };

      // Add conditional location fields
      if (newJob.workLocationType == 'office') {
        body['office_state_id'] = newJob.stateId;
        body['office_district_id'] = newJob.districtId;
        body['office_localite_id'] = newJob.localiteId;
        body['office_address_line1'] = newJob.addressLine1;
        body['office_pincode'] = newJob.pincode;
        if (newJob.addressLine2.isNotEmpty) {
          body['office_address_line2'] = newJob.addressLine2;
        }
      } else if (newJob.workLocationType == 'field') {
        body['field_state_id'] = newJob.stateId;
        body['field_district_id'] = newJob.districtId;
        body['field_localite_id'] = newJob.localiteId;
        body['field_address_line1'] = newJob.addressLine1;
        body['field_pincode'] = newJob.pincode;
        if (newJob.addressLine2.isNotEmpty) {
          body['field_address_line2'] = newJob.addressLine2;
        }
      }

      // Add conditional salary fields
      if (newJob.payType == 'fixed') {
        body['min_salary'] = int.tryParse(newJob.minSalary ?? '') ?? 0;
        body['max_salary'] = int.tryParse(newJob.maxSalary ?? '') ?? 0;
      } else if (newJob.payType == 'fixed_inc') {
        body['fixed_salary'] = int.tryParse(newJob.fixedSalary ?? '') ?? 0;
        body['avg_incentive'] = int.tryParse(newJob.avgIncentive ?? '') ?? 0;
      } else if (newJob.payType == 'inc_only') {
        body['estimated_incentive'] =
            int.tryParse(newJob.estimatedIncentive ?? '') ?? 0;
      }

      // Add conditional walk-in fields
      if (newJob.isWalkin) {
        body['walkin_date'] = newJob.walkinDate;
        body['walkin_time'] = newJob.walkinTime;
        body['walkin_end_time'] = newJob.walkinEndTime;
        body['walkin_venue'] = newJob.walkinVenue;
      }

      // Add conditional contact fields
      if (newJob.contactPreference == 'other') {
        body['contact_person'] = newJob.contactPerson;
        body['contact_phone'] = newJob.contactPhone;
        body['contact_email'] = newJob.contactEmail;
      }

      final res = await ApiService.post(
        ApiRoutes.postJob,
        body: body,
        accessToken: token,
      );

      if (res['status'] == true) {
        await loadDashboard();
      } else {
        throw Failure(res['message'] ?? res['error'] ?? 'Failed to post job');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateApplicationStatus(
    int jobId,
    int appId,
    String status,
  ) async {
    await db.updateApplicationStatus(appId, status);

    // Refresh applicants
    final apps = await db.getJobApplications(jobId);
    jobApplications[jobId] = apps;

    // Update local applications count or lists
    final jobIndex = postedJobs.indexWhere((j) => j.id == jobId);
    if (jobIndex != -1) {
      // Reload dashboard entirely to sync state
      await loadDashboard();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('employer_id');
    await prefs.remove('employer_token');
  }
}
