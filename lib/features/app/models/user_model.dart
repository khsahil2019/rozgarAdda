import '../entity/user_entiity.dart';

class UserModel {
  final int id;

  final String username;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String profileImage;

  const UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return UserModel(
      id: parseId(json['id'] ?? json['candidate_id'] ?? json['user_id']),
      username: json['username']?.toString() ?? '',
      name: (json['name'] ?? json['full_name'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: (json['phone'] ?? json['mobile'])?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      zipCode: (json['zip_code'] ?? json['pincode'])?.toString() ?? '',
      profileImage: (json['profile_image'] ?? json['profile_photo'] ?? json['photo'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'profile_image': profileImage,
    };
  }

  // Convert UserModel to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      state: state,
      country: country,
      zipCode: zipCode,
      profileImage: profileImage,
    );
  }

  // Convert UserEntity to UserModel
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      zipCode: entity.zipCode,
      profileImage: entity.profileImage,
    );
  }
}
