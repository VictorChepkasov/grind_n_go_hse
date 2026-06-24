/// Базовый URL API.
///
/// Для Android-эмулятора: `--dart-define=API_BASE_URL=http://10.0.2.2:5000`
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );
}
