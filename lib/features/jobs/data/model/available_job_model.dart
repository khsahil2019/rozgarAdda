import '../../domain/entities/available_job_entity.dart';

class AvailableJobModel {
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

  AvailableJobModel({
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

  factory AvailableJobModel.fromJson(Map<String, dynamic> json) {
    // Parse skills which can be a JSON string, a list, or null
    List<String> parseSkills(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String) {
        final trimmed = raw.trim();
        if (trimmed.isEmpty) return [];
        // Handle JSON-encoded string like "[\"dds\"]"
        if (trimmed.startsWith('[')) {
          try {
            // Simple manual parse for quoted strings
            final cleaned = trimmed
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .replaceAll("'", '');
            return cleaned
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          } catch (_) {
            return [trimmed];
          }
        }
        return [trimmed];
      }
      return [];
    }

    // Parse string lists safely
    List<String> parseStringList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    // Parse state name from nested object
    String parseStateName(dynamic stateObj) {
      if (stateObj == null) return '';
      if (stateObj is Map<String, dynamic>) {
        return (stateObj['name'] ?? '').toString();
      }
      return '';
    }

    return AvailableJobModel(
      id: _parseInt(json['id']),
      employerId: _parseInt(json['employer_id']),
      categoryId: _parseInt(json['category_id']),
      roleId: _parseInt(json['role_id']),
      title: (json['title'] ?? '').toString(),
      jobType: (json['job_type'] ?? '').toString(),
      shifts: parseStringList(json['shifts']),
      workLocationType: (json['work_location_type'] ?? '').toString(),
      stateName: parseStateName(json['state']),
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
      perks: parseStringList(json['perks']),
      educationLevel: (json['education_level'] ?? '').toString(),
      englishLevel: (json['english_level'] ?? '').toString(),
      experienceLevel: (json['experience_level'] ?? '').toString(),
      additionalRequirements:
          json['additional_requirements'] is Map<String, dynamic>
          ? json['additional_requirements']
          : {},
      skills: parseSkills(json['skills']),
      languages: parseStringList(json['languages']),
      jobDescription: json['job_description']?.toString(),
      vacancy: _parseInt(json['vacancy']),
      isWalkin: json['is_walkin'] == true,
      contactPreference: (json['contact_preference'] ?? '').toString(),
      contactPerson: json['contact_person']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      viewsCount: _parseInt(json['views_count'] ?? json['visitor_count']),
      applicationsCount: _parseInt(json['applications_count']),
      status: (json['status'] ?? '').toString(),
      walkinDate: json['walkin_date']?.toString(),
      walkinTime: json['walkin_time']?.toString(),
      walkinEndTime: json['walkin_end_time']?.toString(),
      walkinVenue: json['walkin_venue']?.toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      stateId: json['state_id'] != null
          ? _parseInt(json['state_id'])
          : (json['office_state_id'] != null
                ? _parseInt(json['office_state_id'])
                : (json['field_state_id'] != null
                      ? _parseInt(json['field_state_id'])
                      : null)),
      districtId: json['district_id'] != null
          ? _parseInt(json['district_id'])
          : (json['office_district_id'] != null
                ? _parseInt(json['office_district_id'])
                : (json['field_district_id'] != null
                      ? _parseInt(json['field_district_id'])
                      : null)),
      localiteId: json['localite_id'] != null
          ? _parseInt(json['localite_id'])
          : (json['office_localite_id'] != null
                ? _parseInt(json['office_localite_id'])
                : (json['field_localite_id'] != null
                      ? _parseInt(json['field_localite_id'])
                      : null)),
      whatsappNumber: json['contact_whatsapp']?.toString(),
      applyOnly: _parseBool(json['apply_only'] ?? true),
      enableCall: json['enable_call'] != null
          ? _parseBool(json['enable_call'])
          : (json['contact_number'] ?? '').toString().isNotEmpty,
      enableChat: json['enable_chat'] != null
          ? _parseBool(json['enable_chat'])
          : (json['contact_whatsapp'] ?? '').toString().isNotEmpty,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  AvailableJob toEntity() {
    return AvailableJob(
      id: id,
      employerId: employerId,
      categoryId: categoryId,
      roleId: roleId,
      title: title,
      jobType: jobType,
      shifts: shifts,
      workLocationType: workLocationType,
      stateName: stateName,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      landmark: landmark,
      pincode: pincode,
      payType: payType,
      minSalary: minSalary,
      maxSalary: maxSalary,
      fixedSalary: fixedSalary,
      avgIncentive: avgIncentive,
      estimatedIncentive: estimatedIncentive,
      perks: perks,
      educationLevel: educationLevel,
      englishLevel: englishLevel,
      experienceLevel: experienceLevel,
      additionalRequirements: additionalRequirements,
      skills: skills,
      languages: languages,
      jobDescription: jobDescription,
      vacancy: vacancy,
      isWalkin: isWalkin,
      contactPreference: contactPreference,
      contactPerson: contactPerson,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      viewsCount: viewsCount,
      applicationsCount: applicationsCount,
      status: status,
      walkinDate: walkinDate,
      walkinTime: walkinTime,
      walkinEndTime: walkinEndTime,
      walkinVenue: walkinVenue,
      createdAt: createdAt,
      stateId: stateId,
      districtId: districtId,
      localiteId: localiteId,
      whatsappNumber: whatsappNumber,
      applyOnly: applyOnly,
      enableCall: enableCall,
      enableChat: enableChat,
    );
  }
}
