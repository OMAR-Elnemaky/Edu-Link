import 'user_role.dart';

class RegistrationData {
  final String name;
  final int age;
  final String email;
  final String password;
  final UserRole? role;

  const RegistrationData({
    required this.name,
    required this.age,
    required this.email,
    required this.password,
    this.role,
  });
}
