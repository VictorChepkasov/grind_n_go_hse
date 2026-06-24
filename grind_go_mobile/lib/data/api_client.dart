import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_exception.dart';

class ApiClient {
  ApiClient({String? Function()? tokenProvider})
      : _tokenProvider = tokenProvider;

  final String? Function()? _tokenProvider;

  Map<String, String> _headers({bool jsonBody = false}) {
    final headers = <String, String>{};
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    final token = _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path) {
    return http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(),
    );
  }

  Future<http.Response> post(String path, {Object? body}) {
    return http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(jsonBody: body != null),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> patch(String path, {Object? body}) {
    return http.patch(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(jsonBody: body != null),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<Map<String, dynamic>> decodeJson(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw ApiException('Некорректный ответ сервера', statusCode: response.statusCode);
    }

    throw ApiException(
      _extractErrorMessage(response),
      statusCode: response.statusCode,
    );
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['title'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}

    return 'Ошибка сервера (${response.statusCode})';
  }

  Future<List<Map<String, dynamic>>> decodeJsonList(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }

      throw ApiException(
        'Некорректный ответ сервера',
        statusCode: response.statusCode,
      );
    }

    throw ApiException(
      _extractErrorMessage(response),
      statusCode: response.statusCode,
    );
  }
}
