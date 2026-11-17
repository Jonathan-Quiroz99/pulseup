// lib/core/api_config.dart

class ApiConfig {

  // La app SIEMPRE habla con la PC del gimnasio (`npm run demo:lan` /
  // `npm run local` en el repo LED GYM), nunca con Render: así el entorno de
  // la presentación es uno solo y no depende de internet.
  //
  // Por defecto: la PC por cable USB (`adb reverse tcp:8000 tcp:8000`). Al
  // arrancar, [BackendResolver] (backend_resolver.dart) también busca la PC
  // en el hotspot de Windows o en la WiFi del celular y actualiza [baseUrl].
  // Ver docs/demo-sin-internet.md en el repo de LED GYM (Proyecto Integrador).
  //
  // Para volver a la nube habría que compilar con
  //   --dart-define=API_BASE_URL=https://membersync-byso.onrender.com
  // (y aun así el resolver prefiere una PC si la encuentra).
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// Servidor en uso ahora mismo. Lo cambia [BackendResolver]; por eso los
  /// servicios deben leerlo en cada petición (getter), nunca copiarlo a una
  /// constante.
  static String baseUrl = defaultBaseUrl;

  static const String apiVersion = '/api';

  static String get fullUrl => '$baseUrl$apiVersion';
}
