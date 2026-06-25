import '../core/api_exception.dart';
import '../core/auth_storage.dart';
import '../core/phone_input.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthRepository {
  AuthRepository({
    ApiClient? client,
    AuthStorage? storage,
  })  : _client = client ?? ApiClient(),
        _storage = storage ?? AuthStorage();

  final ApiClient _client;
  final AuthStorage _storage;

  User? _currentUser;

  User? get currentUser => _currentUser;

  String? get token => _currentUser?.token;

  bool get isAuthenticated => _currentUser != null;

  Future<void> restoreSession() async {
    _currentUser = await _storage.loadSession();
  }

  Future<User> login({
    required String phone,
    required String password,
  }) async {
    final json = await _client.postJson('/api/auth/login', {
      'phoneNumber': normalizePhone(phone),
      'password': password,
    });

    final user = _mapUser(json);
    _currentUser = user;
    await _storage.saveSession(user);
    return user;
  }

  Future<User> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    try {
      final json = await _client.postJson('/api/auth/register', {
        'phoneNumber': normalizePhone(phone),
        'name': name.trim(),
        'password': password,
      });

      final user = _mapUser(json);
      _currentUser = user;
      await _storage.saveSession(user);
      return user;
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        throw AuthException(error.message);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.clearSession();
  }

  User _mapUser(Map<String, dynamic> json) {
    return User(
      id: (json['userId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      phone: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      token: json['token'] as String? ?? '',
    );
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
