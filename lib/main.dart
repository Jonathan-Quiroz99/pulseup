import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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