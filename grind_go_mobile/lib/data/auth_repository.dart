import '../core/api_exception.dart';
import '../core/phone_input.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  String? get token => _currentUser?.token;

  Future<User> login({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/login',
      body: {
        'phoneNumber': normalizePhone(phone),
        'password': password,
      },
    );

    if (response.statusCode == 401) {
      throw ApiException('Неверный телефон или пароль', statusCode: 401);
    }

    final data = await _apiClient.decodeJson(response);
    final user = User.fromJson(data);
    _currentUser = user;
    return user;
  }

  Future<User> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/register',
      body: {
        'phoneNumber': normalizePhone(phone),
        'name': name,
        'password': password,
        'language': 'ru',
      },
    );

    if (response.statusCode == 409) {
      throw ApiException('Этот номер уже зарегистрирован', statusCode: 409);
    }

    final data = await _apiClient.decodeJson(response);
    final user = User.fromJson(data);
    _currentUser = user;
    return user;
  }

  void logout() {
    _currentUser = null;
  }
}
