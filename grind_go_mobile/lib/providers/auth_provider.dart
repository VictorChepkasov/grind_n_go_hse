import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _restoreSession();
  }

  final AuthRepository _repository;

  bool _isRestoring = true;

  bool get isRestoring => _isRestoring;

  User? get user => _repository.currentUser;

  String? get token => _repository.token;

  bool get isAuthenticated => _repository.isAuthenticated;

  Future<void> _restoreSession() async {
    try {
      await _repository.restoreSession();
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    await _repository.login(phone: phone, password: password);
    notifyListeners();
  }

  Future<void> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    await _repository.register(
      phone: phone,
      name: name,
      password: password,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    notifyListeners();
  }
}
