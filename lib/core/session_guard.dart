import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/user_session.dart';

/// Global navigator key so services (which don't have a BuildContext) can
/// redirect to the login screen when the backend reports the session
/// token is invalid or expired (HTTP 401). Wired up in [MaterialApp] in
/// main.dart.
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

bool _handlingExpiredSession = false;

/// Call this whenever an API response comes back 401. Without this, every
/// screen was catching the error independently and just showing an empty
/// state — the user had no idea their session had expired and needed to
/// log in again.
Future<void> handleExpiredSession() async {
  if (_handlingExpiredSession) return;
  _handlingExpiredSession = true;

  try {
    await UserSession.logout();

    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

    // Wait for the new route to finish building before grabbing a
    // BuildContext from it, so ScaffoldMessenger always finds a Scaffold.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootNavigatorKey.currentContext;
      if (context == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión expiró. Inicia sesión de nuevo.'),
        ),
      );
    });
  } finally {
    _handlingExpiredSession = false;
  }
}
