import '../../domain/entities/employer_entity.dart';

class EmployerModel extends Employer {
  const EmployerModel({
    required super.id,
    required super.companyName,
    required super.email,
    required super.phone,
    required super.contactPerson,
    required super.address,
    required super.token,
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) {
    return EmployerModel(
      id: json['id'] as int? ?? 0,
      companyName: (json['company_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      contactPerson: (json['contact_person'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'contact_person': contactPerson,
      'address': address,
      'token': token,
    };
  }
}
