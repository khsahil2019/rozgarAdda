class MissingPerson {
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
  final DateTime? missingDatetime;
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
  final DateTime createdAt;
  final String status;
  final String policeStationNo;
  final String subInspector;
  final String shoNo;

  const MissingPerson({
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

  String get fullImage1Url => image1.isNotEmpty ? 'https://rozgaradda.com/$image1' : '';
  String get fullImage2Url => image2.isNotEmpty ? 'https://rozgaradda.com/$image2' : '';
  String get fullFirCopyUrl => (firCopy != null && firCopy!.isNotEmpty) ? 'https://rozgaradda.com/$firCopy' : '';

  String get fullAddress {
    final parts = [locality, village, district, state, pincode]
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }
}
