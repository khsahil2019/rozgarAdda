class AvailableJob {
  final int id;
  final int employerId;
  final int categoryId;
  final int roleId;
  final String title;
  final String jobType;
  final List<String> shifts;
  final String workLocationType;
  final String stateName;
  final String addressLine1;
  final String addressLine2;
  final String? landmark;
  final String pincode;
  final String payType;
  final String? minSalary;
  final String? maxSalary;
  final String? fixedSalary;
  final String? avgIncentive;
  final String? estimatedIncentive;
  final List<String> perks;
  final String educationLevel;
  final String englishLevel;
  final String experienceLevel;
  final Map<String, dynamic> additionalRequirements;
  final List<String> skills;
  final List<String> languages;
  final String? jobDescription;
  final int vacancy;
  final bool isWalkin;
  final String contactPreference;
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;
  final int viewsCount;
  final int applicationsCount;
  final String status;
  final String? walkinDate;
  final String? walkinTime;
  final String? walkinEndTime;
  final String? walkinVenue;
  final DateTime createdAt;
  final int? stateId;
  final int? districtId;
  final int? localiteId;

  const AvailableJob({
    required this.id,
    required this.employerId,
    required this.categoryId,
    required this.roleId,
    required this.title,
    required this.jobType,
    required this.shifts,
    required this.workLocationType,
    required this.stateName,
    required this.addressLine1,
    required this.addressLine2,
    this.landmark,
    required this.pincode,
    required this.payType,
    this.minSalary,
    this.maxSalary,
    this.fixedSalary,
    this.avgIncentive,
    this.estimatedIncentive,
    required this.perks,
    required this.educationLevel,
    required this.englishLevel,
    required this.experienceLevel,
    required this.additionalRequirements,
    required this.skills,
    required this.languages,
    this.jobDescription,
    required this.vacancy,
    required this.isWalkin,
    required this.contactPreference,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    required this.viewsCount,
    required this.applicationsCount,
    required this.status,
    this.walkinDate,
    this.walkinTime,
    this.walkinEndTime,
    this.walkinVenue,
    required this.createdAt,
    this.stateId,
    this.districtId,
    this.localiteId,
  });

  /// Human-readable salary display string
  String get salaryDisplay {
    if (fixedSalary != null && fixedSalary!.isNotEmpty) {
      return '₹$fixedSalary';
    }
    if (minSalary != null && maxSalary != null) {
      return '₹$minSalary - ₹$maxSalary';
    }
    if (minSalary != null) return '₹$minSalary+';
    return 'Not disclosed';
  }

  /// Human-readable job type label
  String get jobTypeLabel {
    switch (jobType) {
      case 'full_time':
        return 'Full Time';
      case 'part_time':
        return 'Part Time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      default:
        return jobType.replaceAll('_', ' ');
    }
  }

  /// Human-readable work location label
  String get workLocationLabel {
    switch (workLocationType) {
      case 'office':
        return 'Office';
      case 'field':
        return 'Field';
      case 'remote':
        return 'Remote';
      case 'hybrid':
        return 'Hybrid';
      default:
        return workLocationType.replaceAll('_', ' ');
    }
  }

  /// Human-readable experience label
  String get experienceLabel {
    switch (experienceLevel) {
      case 'fresher':
        return 'Fresher';
      default:
        return '$experienceLevel years';
    }
  }
}
