class ApiConfig {
  static const String defaultBaseUrl = 'https://pulseup-api.onrender.com';
  static const String _configuredBaseUrl = String.fromEnvironment(
    'PULSEUP_API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  static String get baseUrl => _configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');

  static Uri get loginUri => Uri.parse('$baseUrl/login');

  static const Duration requestTimeout = Duration(seconds: 15);
}
