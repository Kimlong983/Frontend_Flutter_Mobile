/// Logged-in user (UserRes).
class UserModel {
  final int? id;
  final String username;
  final String? email;
  final List<String> roles;

  UserModel({
    this.id,
    required this.username,
    this.email,
    this.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt(),
      username: json['username']?.toString() ?? 'User',
      email: json['email']?.toString(),
      roles: (json['roles'] as List?)?.map((r) => r.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'roles': roles,
      };
}
