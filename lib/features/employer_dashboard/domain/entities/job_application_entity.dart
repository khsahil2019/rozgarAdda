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
    final candidateMap = json['candidate'] is Map<String, dynamic>
        ? json['candidate'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : null);

    final rawSkills = json['key_skills'] ?? (json['skills'] ?? '');
    String parsedSkills = '';
    if (rawSkills is List) {
      parsedSkills = rawSkills.map((e) => e.toString()).where((s) => s.isNotEmpty).join(', ');
    } else {
      parsedSkills = rawSkills.toString();
      if (parsedSkills == '[]' || parsedSkills == '{}') parsedSkills = '';
    }

    final rawStatus = (json['status'] ?? (json['application_status'] ?? 'pending')).toString();

    return JobApplication(
      id: json['id'] as int? ?? 0,
      jobId: json['job_id'] as int? ?? (json['job_post_id'] as int? ?? 0),
      candidateName: (json['candidate_name'] ??
              (json['full_name'] ??
                  (json['name'] ??
                      (candidateMap?['name'] ??
                          (candidateMap?['full_name'] ?? 'Candidate')))))
          .toString(),
      email: (json['email'] ?? (candidateMap?['email'] ?? '')).toString(),
      phone: (json['phone'] ??
              (json['mobile'] ??
                  (json['contact_number'] ??
                      (candidateMap?['phone'] ?? (candidateMap?['mobile'] ?? '')))))
          .toString(),
      experienceYears:
          (json['experience_years'] ?? (json['experience'] ?? '0')).toString(),
      experienceMonths: (json['experience_months'] ?? '0').toString(),
      educationLevel: (json['education_level'] ??
              (json['education'] ?? (json['qualification'] ?? '')))
          .toString(),
      educationDetails: (json['education_details'] ?? '').toString(),
      keySkills: parsedSkills,
      resumePath: (json['resume_path'] ?? (json['resume'] ?? '')).toString(),
      status: rawStatus.isEmpty ? 'pending' : rawStatus,
      appliedAt: DateTime.tryParse(
              (json['applied_at'] ?? (json['created_at'] ?? '')).toString()) ??
          DateTime.now(),
      expectedSalary: (json['expected_salary'] ?? '').toString(),
      noticePeriod: (json['notice_period'] ?? '').toString(),
    );
  }
}
