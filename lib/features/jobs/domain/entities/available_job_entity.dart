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
  final String? whatsappNumber;
  final bool applyOnly;
  final bool enableCall;
  final bool enableChat;

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
    this.whatsappNumber,
    this.applyOnly = true,
    this.enableCall = false,
    this.enableChat = false,
  });

  /// Helper to format currency numbers with Indian commas (e.g. 20000 -> 20,000, 100000 -> 1,00,000)
  static String formatAmount(String? val) {
    if (val == null || val.trim().isEmpty) return '';
    final clean = val.replaceAll(',', '').replaceAll(' ', '').trim();
    final numVal = num.tryParse(clean);
    if (numVal != null) {
      final isNegative = numVal < 0;
      final absInt = numVal.abs().toInt();
      final str = absInt.toString();
      if (str.length <= 3) {
        return '${isNegative ? "-" : ""}$str';
      }
      final lastThree = str.substring(str.length - 3);
      final remaining = str.substring(0, str.length - 3);
      final buffer = StringBuffer();
      for (int i = 0; i < remaining.length; i++) {
        if (i > 0 && (remaining.length - i) % 2 == 0) {
          buffer.write(',');
        }
        buffer.write(remaining[i]);
      }
      return '${isNegative ? "-" : ""}${buffer.toString()},$lastThree';
    }
    return val;
  }

  /// Human-readable salary display string
  String get salaryDisplay {
    if (fixedSalary != null && fixedSalary!.trim().isNotEmpty) {
      return '₹${formatAmount(fixedSalary)}';
    }
    if (minSalary != null && maxSalary != null && minSalary!.trim().isNotEmpty && maxSalary!.trim().isNotEmpty) {
      return '₹${formatAmount(minSalary)} - ₹${formatAmount(maxSalary)}';
    }
    if (minSalary != null && minSalary!.trim().isNotEmpty) {
      return '₹${formatAmount(minSalary)}+';
    }
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

  /// Whether employer enabled Direct Phone Call button
  bool get showCallButton {
    if (!enableCall &&
        !contactPreference.toLowerCase().contains('call') &&
        !contactPreference.toLowerCase().contains('phone')) {
      return false;
    }
    return (contactPhone != null && contactPhone!.trim().isNotEmpty);
  }

  /// Whether employer enabled WhatsApp / Chat button
  bool get showChatButton {
    if (!enableChat &&
        !contactPreference.toLowerCase().contains('chat') &&
        !contactPreference.toLowerCase().contains('whatsapp')) {
      return false;
    }
    final num = whatsappNumber ?? contactPhone;
    return (num != null && num.trim().isNotEmpty);
  }

  /// Whether employer enabled Direct App Application button
  bool get showApplyButton {
    final pref = contactPreference.toLowerCase();
    // If employer strictly selected only Call and/or Chat without Apply
    if (pref.contains('call_only') ||
        pref.contains('chat_only') ||
        (pref.contains('call') && pref.contains('chat') && !pref.contains('apply'))) {
      return false;
    }
    if (!applyOnly && (showCallButton || showChatButton) && !pref.contains('apply')) {
      return false;
    }
    return true;
  }
}
