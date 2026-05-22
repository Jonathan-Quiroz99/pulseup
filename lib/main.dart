import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PulseUp',
      theme: AppTheme.darkTheme,
      home: LoginScreen(),
    );
  }
}