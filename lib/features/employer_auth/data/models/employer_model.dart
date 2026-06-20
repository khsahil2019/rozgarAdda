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

  factory EmployerModel.fromApiResponse(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return EmployerModel(
      id: user['id'] as int? ?? 0,
      companyName: (user['company_name'] ?? user['username'] ?? '').toString(),
      email: (user['email'] ?? '').toString(),
      phone: (user['phone'] ?? '').toString(),
      contactPerson: (user['username'] ?? '').toString(),
      address: (user['address'] ?? '').toString(),
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
