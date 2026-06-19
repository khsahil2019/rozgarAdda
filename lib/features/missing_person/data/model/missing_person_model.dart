import '../../domain/entities/missing_person.dart';

class MissingPersonModel {
  final int id;
  final String name;
  final String image1;
  final String image2;
  final String relationInfo;
  final String state;
  final String district;
  final String locality;
  final String village;
  final String pincode;
  final String mobile;
  final String reason;
  final String heightFrom;
  final String heightTo;
  final String mentalStatus;
  final String missingDatetime;
  final int age;
  final String gender;
  final String clothes;
  final String identityMark;
  final String complaintName;
  final String complaintMobile;
  final String complaintReason;
  final String complaintIdentityMark;
  final String relationType;
  final String relativeAddress;
  final String firNumber;
  final String? firCopy;
  final String createdAt;
  final String status;
  final String policeStationNo;
  final String subInspector;
  final String shoNo;

  MissingPersonModel({
    required this.id,
    required this.name,
    required this.image1,
    required this.image2,
    required this.relationInfo,
    required this.state,
    required this.district,
    required this.locality,
    required this.village,
    required this.pincode,
    required this.mobile,
    required this.reason,
    required this.heightFrom,
    required this.heightTo,
    required this.mentalStatus,
    required this.missingDatetime,
    required this.age,
    required this.gender,
    required this.clothes,
    required this.identityMark,
    required this.complaintName,
    required this.complaintMobile,
    required this.complaintReason,
    required this.complaintIdentityMark,
    required this.relationType,
    required this.relativeAddress,
    required this.firNumber,
    required this.firCopy,
    required this.createdAt,
    required this.status,
    required this.policeStationNo,
    required this.subInspector,
    required this.shoNo,
  });

  factory MissingPersonModel.fromJson(Map<String, dynamic> json) {
    return MissingPersonModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      image1: json['image1'] as String? ?? '',
      image2: json['image2'] as String? ?? '',
      relationInfo: json['relation_info'] as String? ?? '',
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      locality: json['locality'] as String? ?? '',
      village: json['village'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      heightFrom: json['height_from'] as String? ?? '',
      heightTo: json['height_to'] as String? ?? '',
      mentalStatus: json['mental_status'] as String? ?? '',
      missingDatetime: json['missing_datetime'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      clothes: json['clothes'] as String? ?? '',
      identityMark: json['identity_mark'] as String? ?? '',
      complaintName: json['complaint_name'] as String? ?? '',
      complaintMobile: json['complaint_mobile'] as String? ?? '',
      complaintReason: json['complaint_reason'] as String? ?? '',
      complaintIdentityMark: json['complaint_identity_mark'] as String? ?? '',
      relationType: json['relation_type'] as String? ?? '',
      relativeAddress: json['relative_address'] as String? ?? '',
      firNumber: json['fir_number'] as String? ?? '',
      firCopy: json['fir_copy'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      status: json['status'] as String? ?? '',
      policeStationNo: json['police_station_no'] as String? ?? '',
      subInspector: json['sub_inspector'] as String? ?? '',
      shoNo: json['sho_no'] as String? ?? '',
    );
  }

  MissingPerson toEntity() {
    return MissingPerson(
      id: id,
      name: name,
      image1: image1,
      image2: image2,
      relationInfo: relationInfo,
      state: state,
      district: district,
      locality: locality,
      village: village,
      pincode: pincode,
      mobile: mobile,
      reason: reason,
      heightFrom: heightFrom,
      heightTo: heightTo,
      mentalStatus: mentalStatus,
      missingDatetime: DateTime.tryParse(missingDatetime),
      age: age,
      gender: gender,
      clothes: clothes,
      identityMark: identityMark,
      complaintName: complaintName,
      complaintMobile: complaintMobile,
      complaintReason: complaintReason,
      complaintIdentityMark: complaintIdentityMark,
      relationType: relationType,
      relativeAddress: relativeAddress,
      firNumber: firNumber,
      firCopy: firCopy,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      status: status,
      policeStationNo: policeStationNo,
      subInspector: subInspector,
      shoNo: shoNo,
    );
  }
}
