import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  User? get user => _repository.currentUser;

  String? get token => _repository.token;

  bool get isAuthenticated => _repository.isAuthenticated;

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

  void logout() {
    _repository.logout();
    notifyListeners();
  }
}
