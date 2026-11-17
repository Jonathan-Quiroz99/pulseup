import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'backend_resolver.dart';
import 'session_guard.dart';

/// Timeout applied to every plain API call (login, dashboard, checkin,
/// routines, tienda, tracking...). Render's plan gratuito apaga el backend
/// tras ~15 min sin trafico: la primera peticion despues de dias sin abrir
/// la app puede tardar bastante en "despertarlo". Sin este timeout, esas
/// llamadas (que antes no tenian NINGUN limite) se quedaban esperando para
/// siempre si el arranque en frio fallaba o la conexion se caia a medias,
/// dejando la pantalla con el spinner de carga trabado sin forma de
/// reintentar. Con el timeout, se convierte en un error manejable despues
/// de un tiempo razonable. 60s iguala el criterio que ya usaba por su
/// cuenta el analisis de fotos de nutricion (el unico endpoint que ya
/// tenia timeout antes de este fix).
const Duration apiTimeout = Duration(seconds: 60);

/// Convierte cualquier error de una llamada HTTP en un mensaje entendible
/// para el usuario (sin "Exception:", sin stack traces, sin jerga de red).
String friendlyError(Object error) {
  if (error is SocketException ||
      error is http.ClientException ||
      error is HandshakeException ||
      error is TimeoutException) {
    // Puede que la red haya cambiado (cable desconectado, otra WiFi): se
    // busca la PC de nuevo en segundo plano para el reintento.
    BackendResolver.resolveInBackground();
    return 'No pudimos conectar con el servidor del gimnasio. Revisa que la PC '
        'esté encendida y el celular conectado (cable USB o la misma WiFi).';
  }
  // Errores del plugin de Google Sign-In: antes salia el texto crudo
  // "PlatformException(network_error, m1.d: 7: , null, null)".
  if (error is PlatformException) {
    if (error.code == 'network_error') {
      return 'Google necesita internet en el celular. Sin conexión, entra con tu correo y contraseña.';
    }
    return 'No se pudo iniciar sesión con Google. Intenta de nuevo.';
  }
  var msg = error.toString();
  // "Exception: algo" -> "algo"
  if (msg.startsWith('Exception: ')) msg = msg.substring('Exception: '.length);
  return msg;
}

/// Checks an authenticated API response for a 401 (expired/invalid token)
/// and, if found, redirects the whole app back to the login screen before
/// throwing — instead of letting the calling screen fail silently with an
/// empty state while the user has no idea they were logged out.
///
/// Call this right after every authenticated request, before parsing the
/// body.
Future<void> checkAuthResponse(http.Response response) async {
  if (response.statusCode == 401) {
    await handleExpiredSession();
    throw Exception('Sesión expirada');
  }
}
