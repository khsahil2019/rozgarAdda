class JobApplication {
  final int id;
  final int jobId;
  final String candidateName;
  final String email;
  final String phone;
  final String experienceYears;
  final String experienceMonths;
  final String educationLevel;
  final String educationDetails;
  final String keySkills;
  final String resumePath;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime appliedAt;
  final String expectedSalary;
  final String noticePeriod;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.candidateName,
    required this.email,
    required this.phone,
    required this.experienceYears,
    required this.experienceMonths,
    required this.educationLevel,
    required this.educationDetails,
    required this.keySkills,
    required this.resumePath,
    required this.status,
    required this.appliedAt,
    this.expectedSalary = '',
    this.noticePeriod = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'candidate_name': candidateName,
      'email': email,
      'phone': phone,
      'experience_years': experienceYears,
      'experience_months': experienceMonths,
      'education_level': educationLevel,
      'education_details': educationDetails,
      'key_skills': keySkills,
      'resume_path': resumePath,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'expected_salary': expectedSalary,
      'notice_period': noticePeriod,
    };
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as int? ?? 0,
      jobId: json['job_id'] as int? ?? (json['job_post_id'] as int? ?? 0),
      candidateName: (json['candidate_name'] ?? (json['full_name'] ?? '')).toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      experienceYears: (json['experience_years'] ?? '0').toString(),
      experienceMonths: (json['experience_months'] ?? '0').toString(),
      educationLevel: (json['education_level'] ?? '').toString(),
      educationDetails: (json['education_details'] ?? '').toString(),
      keySkills: (json['key_skills'] ?? '').toString(),
      resumePath: (json['resume_path'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      appliedAt: DateTime.tryParse((json['applied_at'] ?? '').toString()) ?? DateTime.now(),
      expectedSalary: (json['expected_salary'] ?? '').toString(),
      noticePeriod: (json['notice_period'] ?? '').toString(),
    );
  }
}
