import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthStorage {
  static const _sessionKey = 'auth_session';

  Future<void> saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionKey,
      jsonEncode({
        'userId': user.id,
        'name': user.name,
        'phoneNumber': user.phone,
        'role': user.role,
        'token': user.token,
      }),
    );
  }

  Future<User?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final token = json['token'] as String? ?? '';
      if (token.isEmpty) return null;

      return User(
        id: (json['userId'] as num).toInt(),
        name: json['name'] as String? ?? '',
        phone: json['phoneNumber'] as String? ?? '',
        role: json['role'] as String? ?? 'client',
        token: token,
      );
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
