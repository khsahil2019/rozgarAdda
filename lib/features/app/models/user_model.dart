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
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipCode: json['zip_code'] ?? '',
      profileImage: json['profile_image'] ?? '',
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
