class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.token,
    this.role = 'client',
  });

  final int id;
  final String name;
  final String phone;
  final String token;
  final String role;

  bool get isBarista => role == 'barista';

  bool get isClient => role == 'client';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['userId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      phone: json['phoneNumber'] as String? ?? '',
      token: json['token'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
    );
  }
}
