import 'user_role.dart';

class UserEntity {
  final String uid;
  final String email;
  final String fullName;
  final String? profileImage;
  final UserRole role;
  final String? state;
  final String? city;
  final String? locality;
  final String? phoneNumber;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    this.profileImage,
    this.role = UserRole.customer,
    this.state,
    this.city,
    this.locality,
    this.phoneNumber,
  });
}
