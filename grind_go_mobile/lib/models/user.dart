class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.token,
  });

  final int id;
  final String name;
  final String phone;
  final String role;
  final String token;

  bool get isBarista => role == 'barista';
  bool get isClient => role == 'client';
}
