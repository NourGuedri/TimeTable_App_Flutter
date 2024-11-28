class User {
  final String userId;
  final String username;
  final String password;
  final String role;

  User(
      {required this.userId,
      required this.username,
      required this.password,
      required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      password: json['password'],
      role: json['role'],
    );
  }
}
