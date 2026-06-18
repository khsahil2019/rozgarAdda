import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';
import '../../data/models/mock_employer_database.dart';
import '../../domain/entities/job_application_entity.dart';

class EmployerDashboardController extends GetxController {
  final MockEmployerDatabase db = MockEmployerDatabase();

  final RxInt employerId = 0.obs;
  final RxList<AvailableJob> postedJobs = <AvailableJob>[].obs;
  final RxMap<int, List<JobApplication>> jobApplications = <int, List<JobApplication>>{}.obs;
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
      final empId = prefs.getInt('employer_id') ?? 2001; // Fallback to seeded employer
      employerId.value = empId;

      await db.init();
      final jobs = await db.getEmployerJobs(empId);
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
      await db.postJob(newJob);
      await loadDashboard();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateApplicationStatus(int jobId, int appId, String status) async {
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
