import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? token,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
    );

    return _decodeObject(response);
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    String? token,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
    );

    return _decodeList(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return _decodeObject(response);
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic>) return json;
      throw const ApiException('Некорректный ответ сервера.');
    }

    throw ApiException(
      _extractMessage(response.body) ??
          'Ошибка запроса (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  List<dynamic> _decodeList(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      if (json is List<dynamic>) return json;
      throw const ApiException('Некорректный ответ сервера.');
    }

    throw ApiException(
      _extractMessage(response.body) ??
          'Ошибка запроса (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  String? _extractMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final message = json['message'];
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {}
    return null;
  }
}
