class User {
  final int? id;
  final String username;
  final String password;
  final String? role;
  final String? email;

  User({
    this.id,
    required this.username,
    required this.password,
    this.role = 'admin',
    this.email,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String?,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'email': email,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      email: email ?? this.email,
    );
  }
}
