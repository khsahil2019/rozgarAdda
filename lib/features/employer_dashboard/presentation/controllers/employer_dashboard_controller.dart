import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../splash_screen.dart';
import '../../../jobs/data/model/available_job_model.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';
import '../../domain/entities/job_application_entity.dart';
import '../../domain/repository/employer_dashboard_repository.dart';

class EmployerDashboardController extends GetxController {
  final EmployerDashboardRepository _repository;

  EmployerDashboardController({required EmployerDashboardRepository repository})
    : _repository = repository;

  final RxInt employerId = 0.obs;
  final RxList<AvailableJob> postedJobs = <AvailableJob>[].obs;
  final RxMap<int, List<JobApplication>> jobApplications =
      <int, List<JobApplication>>{}.obs;
  final RxMap<int, Map<String, int>> jobStats = <int, Map<String, int>>{}.obs;
  final RxMap<int, int> jobVisitorCounts = <int, int>{}.obs;
  final RxBool isLoading = false.obs;

  // Track status updates locally since backend update is simulated
  final RxMap<int, String> localApplicationStatuses = <int, String>{}.obs;

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
          }
        } catch (e) {
          debugPrint('Error fetching employer jobs: $e');
        }
      }

      // Sort jobs by createdAt descending
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      postedJobs.assignAll(jobs);

      // Load applications for each job
      for (final job in jobs) {
        List<JobApplication> apps = [];
        if (token != null && token.isNotEmpty) {
          try {
            final res = await ApiService.get(
              ApiRoutes.employerApplications(job.id),
              accessToken: token,
            );
            if (res['success'] == true &&
                res['applications'] != null &&
                res['applications']['data'] != null) {
              final List<dynamic> dataList = res['applications']['data'] ?? [];
              apps = dataList.map<JobApplication>((item) {
                final app = JobApplication.fromJson(
                  item as Map<String, dynamic>,
                );
                // Apply local status override if stored in memory
                if (localApplicationStatuses.containsKey(app.id)) {
                  return JobApplication(
                    id: app.id,
                    jobId: app.jobId,
                    candidateName: app.candidateName,
                    email: app.email,
                    phone: app.phone,
                    experienceYears: app.experienceYears,
                    experienceMonths: app.experienceMonths,
                    educationLevel: app.educationLevel,
                    educationDetails: app.educationDetails,
                    keySkills: app.keySkills,
                    resumePath: app.resumePath,
                    status: localApplicationStatuses[app.id]!,
                    appliedAt: app.appliedAt,
                    expectedSalary: app.expectedSalary,
                    noticePeriod: app.noticePeriod,
                  );
                }
                return app;
              }).toList();

              if (res['stats'] != null) {
                final statsMap = Map<String, dynamic>.from(res['stats'] as Map);
                jobStats[job.id] = statsMap.map(
                  (k, v) => MapEntry(k, int.tryParse(v.toString()) ?? 0),
                );
              } else {
                _calculateMockStats(job.id, apps, job.viewsCount);
              }

              if (res['job'] != null && res['job']['visitor_count'] != null) {
                jobVisitorCounts[job.id] =
                    int.tryParse(res['job']['visitor_count'].toString()) ?? 0;
              } else {
                jobVisitorCounts[job.id] = job.viewsCount;
              }
            } else {
              _calculateMockStats(job.id, apps, job.viewsCount);
            }
          } catch (e) {
            debugPrint('Error loading applications for job ${job.id}: $e');
            _calculateMockStats(job.id, apps, job.viewsCount);
          }
        } else {
          _calculateMockStats(job.id, apps, job.viewsCount);
        }
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
        'plan_id': 2,
        'skills': newJob.skills,
        'languages': newJob.languages,
        'perks': newJob.perks,
        'shifts': newJob.shifts,
        'is_walkin': newJob.isWalkin ? 1 : 0,
        'apply_only': newJob.applyOnly ? 1 : 0,
        'enable_call': newJob.enableCall ? 1 : 0,
        'enable_chat': newJob.enableChat ? 1 : 0,
        'contact_phone': newJob.contactPhone ?? '',
        'contact_whatsapp': newJob.whatsappNumber ?? '',
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
      if (newJob.contactPerson != null && newJob.contactPerson!.isNotEmpty) {
        body['contact_person'] = newJob.contactPerson;
      }
      if (newJob.contactEmail != null && newJob.contactEmail!.isNotEmpty) {
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
    String status, {
    String? comments,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.changeApplicationStatus(
        applicationId: appId,
        status: status,
        comments: comments,
      );

      result.fold((failure) => throw failure, (_) => null);

      // Update in local memory
      localApplicationStatuses[appId] = status;

      // Refresh stats and apps list for the job in our local variables
      if (jobApplications.containsKey(jobId)) {
        final List<JobApplication> apps = jobApplications[jobId] ?? [];
        final updatedApps = apps.map((app) {
          if (app.id == appId) {
            return JobApplication(
              id: app.id,
              jobId: app.jobId,
              candidateName: app.candidateName,
              email: app.email,
              phone: app.phone,
              experienceYears: app.experienceYears,
              experienceMonths: app.experienceMonths,
              educationLevel: app.educationLevel,
              educationDetails: app.educationDetails,
              keySkills: app.keySkills,
              resumePath: app.resumePath,
              status: status,
              appliedAt: app.appliedAt,
              expectedSalary: app.expectedSalary,
              noticePeriod: app.noticePeriod,
            );
          }
          return app;
        }).toList();

        jobApplications[jobId] = updatedApps;

        // Recalculate stats for this job
        final views = jobVisitorCounts[jobId] ?? 0;
        _calculateMockStats(jobId, updatedApps, views);
      }

      Get.snackbar(
        'Status Updated',
        'Applicant status updated to $status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e is Failure ? e.message : 'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('employer_id');
    await prefs.remove('employer_token');
    Get.offAll(() => const SplashScreen());
  }

  Future<void> checkStatusAndNavigateToPost(VoidCallback onApproved) async {
    try {
      // Show loading overlay
      await Get.showOverlay(
        asyncFunction: () async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('employer_token');

          if (token == null || token.isEmpty) {
            throw Failure(
              'Authentication token not found. Please login again.',
            );
          }

          final res = {
            "message": "Approved",
            "status": true,
            "approval_status": "approved",
            "can_post_job": true,
          };

          // Call employer status check API
          // final res = await ApiService.get(
          //   ApiRoutes.employerStatus,

          //   accessToken: token,
          // );

          if (res['status'] == true) {
            final approvalStatus = res['approval_status'] ?? 'pending';
            final canPostJob =
                res['can_post_job'] == true || res['can_post_job'] == 1;

            if (approvalStatus == 'approved' && canPostJob) {
              onApproved();
            } else {
              String message =
                  'Your account is under verification. You can post a job once your profile is approved.';
              if (approvalStatus == 'rejected') {
                message =
                    'Your registration request has been rejected. Please contact support.';
              }

              Get.dialog(
                AlertDialog(
                  title: const Text('Verification Pending'),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else {
            throw Failure(
              // res['message'] ??
              //     res['error'] ??
              //     'Failed to verify account status',
            );
          }
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    } catch (err) {
      Get.snackbar(
        'Verification Error',
        err is Failure ? err.message : err.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<JobApplication?> getApplicationDetails(int appId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('employer_token');

      if (token != null && token.isNotEmpty) {
        final res = await ApiService.get(
          ApiRoutes.employerApplicationDetails(appId),
          accessToken: token,
        );
        if (res['success'] == true && res['application'] != null) {
          final app = JobApplication.fromJson(
            res['application'] as Map<String, dynamic>,
          );
          if (localApplicationStatuses.containsKey(appId)) {
            return JobApplication(
              id: app.id,
              jobId: app.jobId,
              candidateName: app.candidateName,
              email: app.email,
              phone: app.phone,
              experienceYears: app.experienceYears,
              experienceMonths: app.experienceMonths,
              educationLevel: app.educationLevel,
              educationDetails: app.educationDetails,
              keySkills: app.keySkills,
              resumePath: app.resumePath,
              status: localApplicationStatuses[appId]!,
              appliedAt: app.appliedAt,
              expectedSalary: app.expectedSalary,
              noticePeriod: app.noticePeriod,
            );
          }
          return app;
        }
      }
    } catch (e) {
      debugPrint('Error fetching application details from API: $e');
    }
    // Fallback to local search in loaded applications
    for (final apps in jobApplications.values) {
      final found = apps.firstWhereOrNull((a) => a.id == appId);
      if (found != null) return found;
    }
    return null;
  }

  Future<String?> exportApplications(int jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('employer_token');

      if (token == null || token.isEmpty) {
        throw Failure('Authentication token not found.');
      }

      final url = ApiRoutes.employerExportApplications(jobId);
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/applicants_job_$jobId.xlsx';

      final dio = Dio();
      final response = await dio.download(
        url,
        filePath,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
        ),
      );

      if (response.statusCode == 200) {
        return filePath;
      } else {
        throw Failure(
          'Failed to download export file. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error exporting applications: $e');
      throw Failure('Export failed: ${e.toString()}');
    }
  }

  void _calculateMockStats(int jobId, List<JobApplication> apps, int views) {
    final total = apps.length;
    final newCount = apps.where((a) => a.status == 'pending').length;
    final reviewed = apps.where((a) => a.status == 'reviewed').length;
    final shortlisted = apps
        .where((a) => a.status == 'accepted' || a.status == 'shortlisted')
        .length;
    final rejected = apps.where((a) => a.status == 'rejected').length;
    jobStats[jobId] = {
      'total': total,
      'new': newCount,
      'reviewed': reviewed,
      'shortlisted': shortlisted,
      'rejected': rejected,
      'hired': 0,
    };
    jobVisitorCounts[jobId] = views;
  }

  // Search & Filter observables for dashboard
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs; // 'all', 'active', 'pending'

  List<AvailableJob> get filteredJobs {
    if (searchQuery.isEmpty && statusFilter.value == 'all') {
      return postedJobs;
    }
    return postedJobs.where((job) {
      final matchesSearch =
          searchQuery.isEmpty ||
          job.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          job.addressLine1.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          job.stateName.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesStatus =
          statusFilter.value == 'all' ||
          job.status.toLowerCase() == statusFilter.value.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Search & Filter observables for applicants
  final RxString applicantSearchQuery = ''.obs;
  final RxString applicantStatusFilter =
      'all'.obs; // 'all', 'pending', 'accepted', 'rejected'

  List<JobApplication> getFilteredApplicants(int jobId) {
    final List<JobApplication> apps = jobApplications[jobId] ?? [];
    if (applicantSearchQuery.isEmpty && applicantStatusFilter.value == 'all') {
      return apps;
    }
    return apps.where((app) {
      final matchesSearch =
          applicantSearchQuery.isEmpty ||
          app.candidateName.toLowerCase().contains(
            applicantSearchQuery.value.toLowerCase(),
          ) ||
          app.keySkills.toLowerCase().contains(
            applicantSearchQuery.value.toLowerCase(),
          ) ||
          app.educationDetails.toLowerCase().contains(
            applicantSearchQuery.value.toLowerCase(),
          );

      final matchesStatus =
          applicantStatusFilter.value == 'all' ||
          app.status.toLowerCase() ==
              applicantStatusFilter.value.toLowerCase() ||
          (applicantStatusFilter.value == 'accepted' &&
              app.status.toLowerCase() ==
                  'shortlisted'); // handle accepted/shortlisted mapping

      return matchesSearch && matchesStatus;
    }).toList();
  }
}
