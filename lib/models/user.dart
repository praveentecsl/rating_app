class User {
  final String userId;
  final String universityId;
  final String name;
  final String role;

  User({
    required this.userId,
    required this.universityId,
    required this.name,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'university_id': universityId,
      'name': name,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, {String? userId}) {
    return User(
      userId: userId ?? map['user_id']?.toString() ?? '',
      universityId: map['university_id'] ?? map['universityId'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
