class ApplicationEntity {
  final int id;
  final String jobTitle;
  final String companyName;
  final String appliedOn;
  final String experience;
  final String expectedSalary;
  final String status; // pending | accepted | rejected

  const ApplicationEntity({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.appliedOn,
    required this.experience,
    required this.expectedSalary,
    required this.status,
  });
}
