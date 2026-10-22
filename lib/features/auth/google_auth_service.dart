import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/http_helpers.dart';
import '../../services/api_service.dart';
import 'register/models/register_models.dart';

/// Resultado de intentar entrar con Google.
///
/// Exactamente uno de estos casos aplica:
/// - [cancelled]     : el usuario cerró el diálogo de Google.
/// - [error]         : algo falló (mensaje ya entendible para mostrar).
/// - [session]       : la cuenta YA existía → sesión iniciada.
/// - [needsRegistration] : NO existe cuenta → hay que elegir plan y crearla.
class GoogleAuthOutcome {
  final bool cancelled;
  final String? error;
  final Map<String, dynamic>? session;
  final RegisterData? needsRegistration;
  final GoogleSignInAccount? googleUser;

  const GoogleAuthOutcome._({
    this.cancelled = false,
    this.error,
    this.session,
    this.needsRegistration,
    this.googleUser,
  });

  bool get isSession => session != null;
  bool get isNewUser => needsRegistration != null;
}

/// Encapsula todo el flujo de "entrar con Google": una sola llamada decide si
/// la persona ya tiene cuenta (inicia sesión) o no (devuelve los datos para
/// crearla). Lo usan tanto la pantalla de login como la de registro.
class GoogleAuthService {
  GoogleAuthService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  // Debe coincidir con el cliente OAuth "Web" del proyecto Firebase
  // (pulseup-1256d): el backend solo acepta ID tokens cuyo `aud` sea este
  // (ver backend/routers/public.py:_verify_google_token). En Web el plugin
  // no acepta `serverClientId` (lee el client id del meta tag en index.html
  // en su lugar), así que solo se pasa en Android/iOS.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    serverClientId: kIsWeb
        ? null
        : '581568965866-j778dj26a5l69i3p7kdddb7kai0evsc2.apps.googleusercontent.com',
  );

  Future<GoogleAuthOutcome> signInOrRegister() async {
    try {
      // signOut primero para que siempre muestre el selector de cuenta.
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const GoogleAuthOutcome._(cancelled: true);
      }

      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const GoogleAuthOutcome._(
          error: 'Google no devolvió un token válido. Inténtalo de nuevo.',
        );
      }

      try {
        final session = await _api.googleLogin(idToken);
        return GoogleAuthOutcome._(session: session, googleUser: googleUser);
      } on GoogleAccountNotFoundException {
        // No hay cuenta: preparamos los datos para el registro con Google.
        final parts = (googleUser.displayName ?? '').trim().split(RegExp(r'\s+'));
        final data = RegisterData(
          nombre: parts.isNotEmpty ? parts.first : '',
          apellidos: parts.length > 1 ? parts.sublist(1).join(' ') : '',
          correo: googleUser.email,
          telefono: '',
          fechaNacimiento: '',
          isGoogle: true,
          googleCredential: idToken,
        );
        return GoogleAuthOutcome._(
          needsRegistration: data,
          googleUser: googleUser,
        );
      }
    } catch (e) {
      return GoogleAuthOutcome._(error: friendlyError(e));
    }
  }
}
