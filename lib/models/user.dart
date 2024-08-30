class User {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String username;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.username,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      username: json['username'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'username': username,
      'role': role,
    };
  }
}
