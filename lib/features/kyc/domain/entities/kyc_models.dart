class KycCandidate {
  final String fullName;
  final String phone;
  final String email;
  final int? stateId;
  final int? districtId;
  final String locality;
  final String pincode;
  final String address;

  const KycCandidate({
    required this.fullName,
    required this.phone,
    required this.email,
    this.stateId,
    this.districtId,
    required this.locality,
    required this.pincode,
    required this.address,
  });
}

class KycDistrict {
  final int id;
  final String name;

  const KycDistrict({
    required this.id,
    required this.name,
  });
}

class KycState {
  final int id;
  final String name;
  final List<KycDistrict> districts;

  const KycState({
    required this.id,
    required this.name,
    required this.districts,
  });
}

class KycDataResponse {
  final KycCandidate candidate;
  final List<KycState> states;

  const KycDataResponse({
    required this.candidate,
    required this.states,
  });
}
