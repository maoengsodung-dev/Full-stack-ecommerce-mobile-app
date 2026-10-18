import '../../../../app/data/models/user_role.dart';

class User {
  final int id;
  final String name;
  final String email;
  final List<String> roles;
  final String? avatar;
  final String? phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.roles = const [],
    this.avatar,
    this.phone,
  });

  bool get isAdmin => roles.contains('admin');
  UserRole get primaryRole => isAdmin ? UserRole.admin : UserRole.customer;
}
