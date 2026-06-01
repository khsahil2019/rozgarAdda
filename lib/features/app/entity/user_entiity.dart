class UserEntity {
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

  const UserEntity({
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
}
