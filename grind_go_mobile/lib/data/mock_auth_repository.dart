import '../models/user.dart';

class MockAuthException implements Exception {
  MockAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Локальное хранилище пользователей до подключения API.
class MockAuthRepository {
  MockAuthRepository._();

  static final MockAuthRepository instance = MockAuthRepository._();

  final Map<String, _StoredUser> _users = {
    '+7 (999) 000-00-00': _StoredUser(
      name: 'Тестовый пользователь',
      password: '1234',
    ),
  };

  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<User> login({
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final stored = _users[phone];
    if (stored == null) {
      throw MockAuthException('Пользователь с таким номером не найден');
    }
    if (stored.password != password) {
      throw MockAuthException('Неверный пароль');
    }

    final user = User(name: stored.name, phone: phone);
    _currentUser = user;
    return user;
  }

  Future<User> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (_users.containsKey(phone)) {
      throw MockAuthException('Этот номер уже зарегистрирован');
    }

    _users[phone] = _StoredUser(name: name.trim(), password: password);
    final user = User(name: name.trim(), phone: phone);
    _currentUser = user;
    return user;
  }

  void logout() {
    _currentUser = null;
  }
}

class _StoredUser {
  const _StoredUser({
    required this.name,
    required this.password,
  });

  final String name;
  final String password;
}
