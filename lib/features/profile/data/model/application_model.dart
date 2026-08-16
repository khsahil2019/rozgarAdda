import '../../domain/entities/application_entity.dart';

class ApplicationModel {
  final int id;
  final String jobTitle;
  final String companyName;
  final String appliedOn;
  final String experience;
  final String expectedSalary;
  final String status;

  const ApplicationModel({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.appliedOn,
    required this.experience,
    required this.expectedSalary,
    required this.status,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      jobTitle: json['job_title']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      appliedOn: json['applied_on']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      expectedSalary: json['expected_salary']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
    );
  }

  ApplicationEntity toEntity() => ApplicationEntity(
        id: id,
        jobTitle: jobTitle,
        companyName: companyName,
        appliedOn: appliedOn,
        experience: experience,
        expectedSalary: expectedSalary,
        status: status,
      );
}
