import '../../domain/entities/kyc_models.dart';

class KycCandidateModel {
  final String fullName;
  final String phone;
  final String email;
  final int? stateId;
  final int? districtId;
  final String locality;
  final String pincode;
  final String address;

  KycCandidateModel({
    required this.fullName,
    required this.phone,
    required this.email,
    this.stateId,
    this.districtId,
    required this.locality,
    required this.pincode,
    required this.address,
  });

  factory KycCandidateModel.fromJson(Map<String, dynamic> json) {
    final rawStateId = json['state_id'];
    final rawDistrictId = json['district_id'];

    return KycCandidateModel(
      fullName: (json['full_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      stateId: rawStateId is int
          ? rawStateId
          : int.tryParse(rawStateId?.toString() ?? ''),
      districtId: rawDistrictId is int
          ? rawDistrictId
          : int.tryParse(rawDistrictId?.toString() ?? ''),
      locality: (json['locality'] ?? '').toString(),
      pincode: (json['pincode'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }

  KycCandidate toEntity() {
    return KycCandidate(
      fullName: fullName,
      phone: phone,
      email: email,
      stateId: stateId,
      districtId: districtId,
      locality: locality,
      pincode: pincode,
      address: address,
    );
  }
}

class KycDistrictModel {
  final int id;
  final String name;

  KycDistrictModel({
    required this.id,
    required this.name,
  });

  factory KycDistrictModel.fromJson(Map<String, dynamic> json) {
    return KycDistrictModel(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }

  KycDistrict toEntity() {
    return KycDistrict(
      id: id,
      name: name,
    );
  }
}

class KycStateModel {
  final int id;
  final String name;
  final List<KycDistrictModel> districts;

  KycStateModel({
    required this.id,
    required this.name,
    required this.districts,
  });

  factory KycStateModel.fromJson(Map<String, dynamic> json) {
    final rawDistricts = json['districts'] as List<dynamic>? ?? [];
    return KycStateModel(
      id: (json['id'] ?? 0) is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      districts: rawDistricts
          .map((e) => KycDistrictModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  KycState toEntity() {
    return KycState(
      id: id,
      name: name,
      districts: districts.map((e) => e.toEntity()).toList(),
    );
  }
}

class KycDataResponseModel {
  final KycCandidateModel candidate;
  final List<KycStateModel> states;

  KycDataResponseModel({
    required this.candidate,
    required this.states,
  });

  factory KycDataResponseModel.fromJson(Map<String, dynamic> json) {
    return KycDataResponseModel(
      candidate: KycCandidateModel.fromJson(
        json['candidate'] as Map<String, dynamic>? ?? {},
      ),
      states: (json['states'] as List<dynamic>? ?? [])
          .map((e) => KycStateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  KycDataResponse toEntity() {
    return KycDataResponse(
      candidate: candidate.toEntity(),
      states: states.map((e) => e.toEntity()).toList(),
    );
  }
}
