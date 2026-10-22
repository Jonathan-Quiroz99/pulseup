// lib/core/api_config.dart

class ApiConfig {

  // Backend en Render (producción). Se puede sobreescribir en tiempo de build:
  //   flutter run --dart-define=API_BASE_URL=http://localhost:8000
  //
  // Ya NO hace falta recompilar para el demo sin internet: al arrancar,
  // [BackendResolver] (backend_resolver.dart) busca solo el servidor que
  // responda — Render, la PC por cable USB (`adb reverse`), el hotspot de
  // Windows o cualquier PC de la red WiFi del celular corriendo
  // `npm run demo:lan` — y actualiza [baseUrl]. Ver
  // docs/demo-sin-internet.md en el repo de LED GYM (Proyecto Integrador).
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://membersync-byso.onrender.com',
  );

  /// Servidor en uso ahora mismo. Lo cambia [BackendResolver]; por eso los
  /// servicios deben leerlo en cada petición (getter), nunca copiarlo a una
  /// constante.
  static String baseUrl = defaultBaseUrl;

  static const String apiVersion = '/api';

  static String get fullUrl => '$baseUrl$apiVersion';
}
