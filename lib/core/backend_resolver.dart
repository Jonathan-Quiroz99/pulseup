import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// Encuentra solo a qué servidor hablarle, para que la app funcione aunque
/// la red del lugar bloquee Render o no haya internet — sin recompilar el
/// APK ni escribir IPs.
///
/// Orden de preferencia:
///   1. Servidor elegido a mano (ver [setManualOverride]); si existe, gana.
///   2. Render ([ApiConfig.defaultBaseUrl]) si responde a tiempo.
///   3. La PC con `npm run demo:lan` (repo LED GYM):
///      - la última IP de PC que funcionó,
///      - `127.0.0.1:8000` (cable USB + `adb reverse tcp:8000 tcp:8000`),
///      - `192.168.137.1:8000` (hotspot móvil de Windows),
///      - escaneo de la red WiFi / hotspot del celular buscando el puerto 8000.
///   4. Si nada responde, se queda con Render (puede estar "despertando").
///
/// Un servidor solo cuenta si `/api/health` dice `service: membersync-api` y
/// `status: ok` (base de datos conectada), para no confundirlo con cualquier
/// otra cosa que escuche en el puerto 8000.
class BackendResolver {
  BackendResolver._();

  static const int lanPort = 8000;
  static const String _prefsOverride = 'backend_manual_url';
  static const String _prefsLastLan = 'backend_last_lan_url';

  /// Cuánto se espera a Render antes de preferir la PC local. Render gratis
  /// tarda ~50 s en despertar; si en este tiempo no contesta y hay una PC en
  /// la red, se usa la PC.
  static const Duration _primaryTimeout = Duration(seconds: 6);
  static const Duration _lanHealthTimeout = Duration(milliseconds: 2500);
  static const Duration _scanConnectTimeout = Duration(milliseconds: 700);
  static const int _scanBatchSize = 64;

  // Interfaces de datos móviles / VPN: escanearlas no tiene sentido (la PC
  // nunca está ahí) y solo haría más lento el arranque.
  static final RegExp _skipInterface =
      RegExp(r'rmnet|ccmni|pdp|dummy|tun|ppp|ipsec|clat', caseSensitive: false);

  static Future<String>? _inFlight;
  static DateTime? _lastBackgroundRun;
  // Sube cada vez que el usuario elige servidor a mano: una búsqueda
  // automática que ya estaba en curso no debe pisar esa elección.
  static int _generation = 0;

  /// Busca el servidor y actualiza [ApiConfig.baseUrl]. Si ya hay una
  /// búsqueda en curso, espera esa misma en vez de lanzar otra.
  static Future<String> resolve() {
    return _inFlight ??= _resolve().whenComplete(() => _inFlight = null);
  }

  static void _apply(int generation, String url) {
    if (generation == _generation) ApiConfig.baseUrl = url;
  }

  /// Re-busca el servidor sin bloquear (tras un error de red o al volver a
  /// la app), como mucho una vez cada 15 s. El siguiente "reintentar" del
  /// usuario ya usa el servidor nuevo.
  static void resolveInBackground() {
    final now = DateTime.now();
    final last = _lastBackgroundRun;
    if (last != null && now.difference(last) < const Duration(seconds: 15)) {
      return;
    }
    _lastBackgroundRun = now;
    unawaited(resolve());
  }

  static Future<String?> manualOverride() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_prefsOverride);
      return (value == null || value.isEmpty) ? null : value;
    } catch (_) {
      return null;
    }
  }

  /// Fija el servidor a mano (`null` = volver a automático). Acepta
  /// `192.168.1.50`, `192.168.1.50:8000` o una URL completa. Solo se guarda si
  /// ese servidor responde; si no, lanza [FormatException] con el motivo y no
  /// cambia nada (así un error de dedo no deja la app apuntando a la nada).
  static Future<String> setManualOverride(String? input) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = input == null ? null : normalizeServerInput(input);
    if (normalized == null) {
      await prefs.remove(_prefsOverride);
      _generation++;
      _inFlight = null;
      return resolve();
    }
    if (!await _isOurBackend(normalized, _lanHealthTimeout)) {
      throw FormatException(
          'No hay servidor PulseUp en $normalized. Revisa la IP, que la PC '
          'corra "npm run demo:lan" y que el firewall permita el puerto $lanPort.');
    }
    await prefs.setString(_prefsOverride, normalized);
    _generation++;
    ApiConfig.baseUrl = normalized;
    return normalized;
  }

  /// `192.168.1.50` -> `http://192.168.1.50:8000`; URLs con esquema se
  /// respetan tal cual (sin `/` final). Devuelve `null` si queda vacío.
  static String? normalizeServerInput(String input) {
    var value = input.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.isEmpty) return null;
    if (value.contains('://')) {
      final uri = Uri.tryParse(value);
      if (uri == null ||
          !(uri.scheme == 'http' || uri.scheme == 'https') ||
          uri.host.isEmpty) {
        return null;
      }
      return value;
    }
    final hasPort = RegExp(r':\d+$').hasMatch(value);
    return 'http://$value${hasPort ? '' : ':$lanPort'}';
  }

  static Future<String> _resolve() async {
    // En web no hay sockets crudos ni acceso a la red local; se queda con la
    // URL de compilación.
    if (kIsWeb) return ApiConfig.baseUrl;

    final generation = _generation;
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {}

    final manual = prefs?.getString(_prefsOverride);
    if (manual != null && manual.isNotEmpty) {
      _apply(generation, manual);
      return ApiConfig.baseUrl;
    }

    // Render y la búsqueda local corren en paralelo para no sumar tiempos.
    final primaryFuture =
        _isOurBackend(ApiConfig.defaultBaseUrl, _primaryTimeout);
    final localFuture = _findLocalBackend(prefs?.getString(_prefsLastLan));

    if (await primaryFuture) {
      _apply(generation, ApiConfig.defaultBaseUrl);
      return ApiConfig.baseUrl;
    }

    final local = await localFuture;
    if (local != null) {
      _apply(generation, local);
      try {
        await prefs?.setString(_prefsLastLan, local);
      } catch (_) {}
      return ApiConfig.baseUrl;
    }

    _apply(generation, ApiConfig.defaultBaseUrl);
    return ApiConfig.baseUrl;
  }

  // -------------------------------------------------------------------------
  // Servidor para la IA de nutricion
  // -------------------------------------------------------------------------
  //
  // Render tiene la IA desactivada (Claude cuesta) y no puede llegar a Gemma,
  // que corre en la PC del gimnasio. Aunque la app use la nube para todo lo
  // demas, el analisis de la foto se puede mandar a una PC de la misma red
  // con `npm run demo:lan`: el analisis no guarda nada (la comida se guarda
  // despues en el servidor normal) y la PC acepta la misma sesion porque
  // comparte SECRET_KEY con Render.

  static String? _aiServer;
  static DateTime? _aiServerCheckedAt;
  static Future<String?>? _aiInFlight;

  /// Una PC en la red local con IA de nutricion disponible, o `null`.
  /// Una PC encontrada se recuerda 5 minutos para no escanear la red en cada
  /// foto; un "no hay PC" solo 15 s, para que si la encienden despues el
  /// siguiente intento ya la encuentre.
  static Future<String?> findAiServer({bool forceRefresh = false}) {
    final checkedAt = _aiServerCheckedAt;
    final ttl = _aiServer != null
        ? const Duration(minutes: 5)
        : const Duration(seconds: 15);
    if (!forceRefresh &&
        checkedAt != null &&
        DateTime.now().difference(checkedAt) < ttl) {
      return Future.value(_aiServer);
    }
    return _aiInFlight ??= _findAiServer().then((url) {
      _aiServer = url;
      _aiServerCheckedAt = DateTime.now();
      return url;
    }).whenComplete(() => _aiInFlight = null);
  }

  /// Olvida la PC de IA recordada (p. ej. dejo de responder).
  static void forgetAiServer() {
    _aiServer = null;
    _aiServerCheckedAt = null;
  }

  static Future<String?> _findAiServer() async {
    if (kIsWeb) return null;
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {}
    return _findLocalBackend(
      prefs?.getString(_prefsLastLan),
      requireNutritionAi: true,
    );
  }

  static Future<String?> _findLocalBackend(String? lastLan,
      {bool requireNutritionAi = false}) async {
    final fixed = <String>[
      if (lastLan != null && lastLan.isNotEmpty) lastLan,
      'http://127.0.0.1:$lanPort',
      'http://192.168.137.1:$lanPort',
    ];
    final unique = fixed.toSet().toList();
    final checks = await Future.wait(
      unique.map((url) => _isOurBackend(url, _lanHealthTimeout,
          requireNutritionAi: requireNutritionAi)),
    );
    for (var i = 0; i < unique.length; i++) {
      if (checks[i]) return unique[i];
    }

    for (final host in await _scanLocalSubnets()) {
      final url = 'http://$host:$lanPort';
      if (await _isOurBackend(url, _lanHealthTimeout,
          requireNutritionAi: requireNutritionAi)) {
        return url;
      }
    }
    return null;
  }

  /// Hosts de las redes /24 del celular (WiFi o su propio hotspot) que
  /// tienen abierto el puerto [lanPort].
  static Future<List<String>> _scanLocalSubnets() async {
    final List<NetworkInterface> interfaces;
    try {
      interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    } catch (_) {
      return const [];
    }

    final ownAddresses = <String>{};
    final prefixes = <String>{};
    for (final iface in interfaces) {
      if (_skipInterface.hasMatch(iface.name)) continue;
      for (final addr in iface.addresses) {
        if (addr.isLoopback || addr.isLinkLocal) continue;
        final parts = addr.address.split('.');
        if (parts.length != 4 || !_isPrivate(parts)) continue;
        ownAddresses.add(addr.address);
        prefixes.add('${parts[0]}.${parts[1]}.${parts[2]}');
      }
    }

    final open = <String>[];
    for (final prefix in prefixes) {
      final hosts = [
        for (var i = 1; i <= 254; i++) '$prefix.$i',
      ]..removeWhere(ownAddresses.contains);
      for (var start = 0; start < hosts.length; start += _scanBatchSize) {
        final batch = hosts.skip(start).take(_scanBatchSize).toList();
        final results = await Future.wait(batch.map(_isPortOpen));
        for (var i = 0; i < batch.length; i++) {
          if (results[i]) open.add(batch[i]);
        }
      }
    }
    return open;
  }

  static bool _isPrivate(List<String> octets) {
    final a = int.tryParse(octets[0]) ?? -1;
    final b = int.tryParse(octets[1]) ?? -1;
    return a == 10 ||
        (a == 192 && b == 168) ||
        (a == 172 && b >= 16 && b <= 31);
  }

  static Future<bool> _isPortOpen(String host) async {
    try {
      final socket =
          await Socket.connect(host, lanPort, timeout: _scanConnectTimeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _isOurBackend(String baseUrl, Duration timeout,
      {bool requireNutritionAi = false}) async {
    final inner = HttpClient()..connectionTimeout = timeout;
    final client = IOClient(inner);
    try {
      final res = await client
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(timeout);
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      if (data is! Map ||
          data['service'] != 'membersync-api' ||
          data['status'] != 'ok') {
        return false;
      }
      // Para la IA solo cuenta una PC que diga que la tiene; asi no se elige
      // un backend viejo o sin IA y se sigue buscando la PC con Gemma.
      return !requireNutritionAi ||
          data['nutrition_ai'] == 'ollama' ||
          data['nutrition_ai'] == 'claude';
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }
}
