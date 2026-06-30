import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';
import '../../domain/entities/job_application_entity.dart';

class MockEmployerDatabase {
  static final MockEmployerDatabase _instance =
      MockEmployerDatabase._internal();
  factory MockEmployerDatabase() => _instance;
  MockEmployerDatabase._internal();

  List<AvailableJob> _jobs = [];
  List<JobApplication> _applications = [];
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();

    // Load Jobs
    final String? jobsJson = prefs.getString('mock_db_jobs');
    if (jobsJson != null && jobsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jobsJson);
        _jobs = decoded
            .map((item) => _jobFromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // _seedDefaultJobs();
      }
    } else {
      // _seedDefaultJobs();
    }

    // Load Applications
    final String? appsJson = prefs.getString('mock_db_applications');
    if (appsJson != null && appsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(appsJson);
        _applications = decoded
            .map(
              (item) => JobApplication.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } catch (_) {
        _seedDefaultApplications();
      }
    } else {
      _seedDefaultApplications();
    }

    _isInitialized = true;
    await _saveToStorage();
  }

  void _seedDefaultApplications() {
    _applications = [
      JobApplication(
        id: 3001,
        jobId: 1001,
        candidateName: 'Rahul Sharma',
        email: 'rahul.sharma@example.com',
        phone: '9829012345',
        experienceYears: '0',
        experienceMonths: '6',
        educationLevel: '12th Pass',
        educationDetails: 'Govt Senior Secondary School',
        keySkills: 'Bike Driving, Map Navigation',
        resumePath: '/mock/resume_rahul.pdf',
        status: 'pending',
        appliedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      JobApplication(
        id: 3002,
        jobId: 1001,
        candidateName: 'Amit Verma',
        email: 'amit.verma@example.com',
        phone: '9116045678',
        experienceYears: '2',
        experienceMonths: '0',
        educationLevel: '10th Pass',
        educationDetails: 'Jaipur Public School',
        keySkills: 'Fast Driving, Local Route Expert',
        resumePath: '/mock/resume_amit.pdf',
        status: 'accepted',
        appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      JobApplication(
        id: 3003,
        jobId: 1002,
        candidateName: 'Priya Patel',
        email: 'priya.patel@example.com',
        phone: '9414078901',
        experienceYears: '1',
        experienceMonths: '2',
        educationLevel: 'Graduate',
        educationDetails: 'B.Com - Rajasthan University',
        keySkills: 'MS Office, Data Entry, Excel',
        resumePath: '/mock/resume_priya.pdf',
        status: 'pending',
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Save Jobs
    final List<Map<String, dynamic>> serializedJobs = _jobs
        .map((j) => _jobToMap(j))
        .toList();
    await prefs.setString('mock_db_jobs', jsonEncode(serializedJobs));

    // Save Applications
    final List<Map<String, dynamic>> serializedApps = _applications
        .map((a) => a.toJson())
        .toList();
    await prefs.setString('mock_db_applications', jsonEncode(serializedApps));
  }

  // Database Accessors
  Future<List<AvailableJob>> getAllJobs() async {
    await init();
    return _jobs;
  }

  Future<List<AvailableJob>> getEmployerJobs(int employerId) async {
    await init();
    return _jobs.where((job) => job.employerId == employerId).toList();
  }

  Future<List<JobApplication>> getJobApplications(int jobId) async {
    await init();
    return _applications.where((app) => app.jobId == jobId).toList();
  }

  Future<void> postJob(AvailableJob job) async {
    await init();

    // Assign a new ID if it's 0/placeholder
    final newId = job.id == 0 || job.id == -1
        ? (_jobs.isEmpty
              ? 1001
              : _jobs.map((j) => j.id).reduce((a, b) => a > b ? a : b) + 1)
        : job.id;

    final jobWithId = AvailableJob(
      id: newId,
      employerId: job.employerId,
      categoryId: job.categoryId,
      roleId: job.roleId,
      title: job.title,
      jobType: job.jobType,
      shifts: job.shifts,
      workLocationType: job.workLocationType,
      stateName: job.stateName,
      addressLine1: job.addressLine1,
      addressLine2: job.addressLine2,
      landmark: job.landmark,
      pincode: job.pincode,
      payType: job.payType,
      minSalary: job.minSalary,
      maxSalary: job.maxSalary,
      fixedSalary: job.fixedSalary,
      avgIncentive: job.avgIncentive,
      estimatedIncentive: job.estimatedIncentive,
      perks: job.perks,
      educationLevel: job.educationLevel,
      englishLevel: job.englishLevel,
      experienceLevel: job.experienceLevel,
      additionalRequirements: job.additionalRequirements,
      skills: job.skills,
      languages: job.languages,
      jobDescription: job.jobDescription,
      vacancy: job.vacancy,
      isWalkin: job.isWalkin,
      contactPreference: job.contactPreference,
      contactPerson: job.contactPerson,
      contactPhone: job.contactPhone,
      contactEmail: job.contactEmail,
      viewsCount: job.viewsCount,
      applicationsCount: job.applicationsCount,
      status: job.status,
      walkinDate: job.walkinDate,
      walkinTime: job.walkinTime,
      walkinEndTime: job.walkinEndTime,
      walkinVenue: job.walkinVenue,
      createdAt: job.createdAt,
      stateId: job.stateId,
      districtId: job.districtId,
      localiteId: job.localiteId,
      whatsappNumber: job.whatsappNumber,
      applyOnly: job.applyOnly,
      enableCall: job.enableCall,
      enableChat: job.enableChat,
    );

    _jobs.add(jobWithId);
    await _saveToStorage();
  }

  Future<void> applyToJob(JobApplication app) async {
    await init();

    final newId = app.id == 0
        ? (_applications.isEmpty
              ? 3001
              : _applications.map((a) => a.id).reduce((a, b) => a > b ? a : b) +
                    1)
        : app.id;

    final appWithId = JobApplication(
      id: newId,
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
      status: app.status,
      appliedAt: app.appliedAt,
    );

    _applications.add(appWithId);

    // Update applications count in job
    final jobIndex = _jobs.indexWhere((j) => j.id == app.jobId);
    if (jobIndex != -1) {
      final oldJob = _jobs[jobIndex];
      _jobs[jobIndex] = AvailableJob(
        id: oldJob.id,
        employerId: oldJob.employerId,
        categoryId: oldJob.categoryId,
        roleId: oldJob.roleId,
        title: oldJob.title,
        jobType: oldJob.jobType,
        shifts: oldJob.shifts,
        workLocationType: oldJob.workLocationType,
        stateName: oldJob.stateName,
        addressLine1: oldJob.addressLine1,
        addressLine2: oldJob.addressLine2,
        landmark: oldJob.landmark,
        pincode: oldJob.pincode,
        payType: oldJob.payType,
        minSalary: oldJob.minSalary,
        maxSalary: oldJob.maxSalary,
        fixedSalary: oldJob.fixedSalary,
        avgIncentive: oldJob.avgIncentive,
        estimatedIncentive: oldJob.estimatedIncentive,
        perks: oldJob.perks,
        educationLevel: oldJob.educationLevel,
        englishLevel: oldJob.englishLevel,
        experienceLevel: oldJob.experienceLevel,
        additionalRequirements: oldJob.additionalRequirements,
        skills: oldJob.skills,
        languages: oldJob.languages,
        jobDescription: oldJob.jobDescription,
        vacancy: oldJob.vacancy,
        isWalkin: oldJob.isWalkin,
        contactPreference: oldJob.contactPreference,
        contactPerson: oldJob.contactPerson,
        contactPhone: oldJob.contactPhone,
        contactEmail: oldJob.contactEmail,
        viewsCount: oldJob.viewsCount,
        applicationsCount: oldJob.applicationsCount + 1,
        status: oldJob.status,
        walkinDate: oldJob.walkinDate,
        walkinTime: oldJob.walkinTime,
        walkinEndTime: oldJob.walkinEndTime,
        walkinVenue: oldJob.walkinVenue,
        createdAt: oldJob.createdAt,
        stateId: oldJob.stateId,
        districtId: oldJob.districtId,
        localiteId: oldJob.localiteId,
        whatsappNumber: oldJob.whatsappNumber,
        applyOnly: oldJob.applyOnly,
        enableCall: oldJob.enableCall,
        enableChat: oldJob.enableChat,
      );
    }

    await _saveToStorage();
  }

  Future<void> updateApplicationStatus(int applicationId, String status) async {
    await init();
    final appIndex = _applications.indexWhere((a) => a.id == applicationId);
    if (appIndex != -1) {
      final oldApp = _applications[appIndex];
      _applications[appIndex] = JobApplication(
        id: oldApp.id,
        jobId: oldApp.jobId,
        candidateName: oldApp.candidateName,
        email: oldApp.email,
        phone: oldApp.phone,
        experienceYears: oldApp.experienceYears,
        experienceMonths: oldApp.experienceMonths,
        educationLevel: oldApp.educationLevel,
        educationDetails: oldApp.educationDetails,
        keySkills: oldApp.keySkills,
        resumePath: oldApp.resumePath,
        status: status,
        appliedAt: oldApp.appliedAt,
      );
      await _saveToStorage();
    }
  }

  // Serialization Helpers
  Map<String, dynamic> _jobToMap(AvailableJob job) {
    return {
      'id': job.id,
      'employer_id': job.employerId,
      'category_id': job.categoryId,
      'role_id': job.roleId,
      'title': job.title,
      'job_type': job.jobType,
      'shifts': job.shifts,
      'work_location_type': job.workLocationType,
      'state': {'name': job.stateName},
      'address_line1': job.addressLine1,
      'address_line2': job.addressLine2,
      'landmark': job.landmark,
      'pincode': job.pincode,
      'pay_type': job.payType,
      'min_salary': job.minSalary,
      'max_salary': job.maxSalary,
      'fixed_salary': job.fixedSalary,
      'avg_incentive': job.avgIncentive,
      'estimated_incentive': job.estimatedIncentive,
      'perks': job.perks,
      'education_level': job.educationLevel,
      'english_level': job.englishLevel,
      'experience_level': job.experienceLevel,
      'additional_requirements': job.additionalRequirements,
      'skills': job.skills,
      'languages': job.languages,
      'job_description': job.jobDescription,
      'vacancy': job.vacancy,
      'is_walkin': job.isWalkin,
      'contact_preference': job.contactPreference,
      'contact_person': job.contactPerson,
      'contact_phone': job.contactPhone,
      'contact_email': job.contactEmail,
      'views_count': job.viewsCount,
      'applications_count': job.applicationsCount,
      'status': job.status,
      'walkin_date': job.walkinDate,
      'walkin_time': job.walkinTime,
      'walkin_end_time': job.walkinEndTime,
      'walkin_venue': job.walkinVenue,
      'created_at': job.createdAt.toIso8601String(),
      'state_id': job.stateId,
      'district_id': job.districtId,
      'localite_id': job.localiteId,
      'apply_only': job.applyOnly ? 1 : 0,
      'enable_call': job.enableCall ? 1 : 0,
      'enable_chat': job.enableChat ? 1 : 0,
      'contact_whatsapp': job.whatsappNumber,
    };
  }

  AvailableJob _jobFromMap(Map<String, dynamic> json) {
    final stateObj = json['state'];
    final stateName = stateObj is Map
        ? (stateObj['name'] ?? '').toString()
        : '';

    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    return AvailableJob(
      id: json['id'] as int? ?? 0,
      employerId: json['employer_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      roleId: json['role_id'] as int? ?? 0,
      title: (json['title'] ?? '').toString(),
      jobType: (json['job_type'] ?? '').toString(),
      shifts: parseList(json['shifts']),
      workLocationType: (json['work_location_type'] ?? '').toString(),
      stateName: stateName.isEmpty
          ? (json['stateName'] ?? '').toString()
          : stateName,
      addressLine1: (json['address_line1'] ?? '').toString(),
      addressLine2: (json['address_line2'] ?? '').toString(),
      landmark: json['landmark']?.toString(),
      pincode: (json['pincode'] ?? '').toString(),
      payType: (json['pay_type'] ?? '').toString(),
      minSalary: json['min_salary']?.toString(),
      maxSalary: json['max_salary']?.toString(),
      fixedSalary: json['fixed_salary']?.toString(),
      avgIncentive: json['avg_incentive']?.toString(),
      estimatedIncentive: json['estimated_incentive']?.toString(),
      perks: parseList(json['perks']),
      educationLevel: (json['education_level'] ?? '').toString(),
      englishLevel: (json['english_level'] ?? '').toString(),
      experienceLevel: (json['experience_level'] ?? '').toString(),
      additionalRequirements: (json['additional_requirements'] is Map
          ? json['additional_requirements'] as Map<String, dynamic>
          : <String, dynamic>{}),
      skills: parseList(json['skills']),
      languages: parseList(json['languages']),
      jobDescription: json['job_description']?.toString(),
      vacancy: json['vacancy'] as int? ?? 0,
      isWalkin: json['is_walkin'] == true,
      contactPreference: (json['contact_preference'] ?? '').toString(),
      contactPerson: json['contact_person']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      viewsCount: json['views_count'] as int? ?? 0,
      applicationsCount: json['applications_count'] as int? ?? 0,
      status: (json['status'] ?? '').toString(),
      walkinDate: json['walkin_date']?.toString(),
      walkinTime: json['walkin_time']?.toString(),
      walkinEndTime: json['walkin_end_time']?.toString(),
      walkinVenue: json['walkin_venue']?.toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      stateId: json['state_id'] as int?,
      districtId: json['district_id'] as int?,
      localiteId: json['localite_id'] as int?,
      whatsappNumber: json['contact_whatsapp']?.toString(),
      applyOnly: json['apply_only'] == 1 || json['apply_only'] == true || json['apply_only'] == null,
      enableCall: json['enable_call'] == 1 || json['enable_call'] == true,
      enableChat: json['enable_chat'] == 1 || json['enable_chat'] == true,
    );
  }
}
