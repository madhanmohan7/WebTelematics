class User {
  String name;
  String email;
  String mobile;
  String team; // BMS Team or Thermal Team
  String role; // Admin or User
  String username;
  String password;

  User({
    required this.name,
    required this.email,
    required this.mobile,
    required this.team,
    required this.role,
    required this.username,
    required this.password,
  });
}