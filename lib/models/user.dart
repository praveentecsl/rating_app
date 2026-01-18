class User {
  final int? userId;
  final String universityId;
  final String name;
  final String role;
  final String password;

  User({
    this.userId,
    required this.universityId,
    required this.name,
    required this.role,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'university_id': universityId,
      'name': name,
      'role': role,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      universityId: map['university_id'],
      name: map['name'],
      role: map['role'],
      password: map['password'],
    );
  }
}
