import 'package:flutter/material.dart';
import 'core/backend_resolver.dart';
import 'core/session_guard.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/user_session.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'PulseUp',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const _StartupGate(),
    );
  }
}

/// Decides whether to send the user to [HomeScreen] (session already saved
/// on-device) or [LoginScreen] (no saved session) while the app boots.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate>
    with WidgetsBindingObserver {
  late final Future<bool> _hasSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Buscar el servidor (nube, PC por cable o PC en la WiFi) antes de que
    // la primera pantalla haga peticiones.
    _hasSession = Future.wait([
      UserSession.restoreSession(),
      // Tope: pase lo que pase con la red, la app arranca (con Render).
      BackendResolver.resolve().timeout(
        const Duration(seconds: 12),
        onTimeout: () => '',
      ),
    ]).then((results) => results.first as bool);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al volver a la app la red pudo cambiar (otra WiFi, cable conectado).
    if (state == AppLifecycleState.resumed) {
      BackendResolver.resolveInBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Buscando servidor…'),
                ],
              ),
            ),
          );
        }

        return snapshot.data == true
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}
