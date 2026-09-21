// lib/core/api_config.dart

class ApiConfig {

  // Backend en Render (producción). Se puede sobreescribir en tiempo de build
  // para apuntar a un backend local:
  //   flutter run --dart-define=API_BASE_URL=http://localhost:8000
  // (con `adb reverse tcp:8000 tcp:8000` para llegar al PC por USB).
  //
  // Demo SIN internet (celular por WiFi/hotspot, sin cable): compilar un APK
  // de release apuntando a la IP de LAN de la PC en vez de localhost —
  //   flutter build apk --release --dart-define=API_BASE_URL=http://<IP-PC>:8000
  // con el backend corriendo `npm run demo:lan` en el repo de LED GYM
  // (Proyecto Integrador). Ver docs/demo-sin-internet.md ahi para el detalle.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://membersync-byso.onrender.com',
  );

  static const String apiVersion = '/api';

  static const String fullUrl =
      '$baseUrl$apiVersion';
}