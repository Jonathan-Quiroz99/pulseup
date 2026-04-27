import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://bjrmuhqjhrjjekvvmpae.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqcm11aHFqaHJqamVrdnZtcGFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNjY1MTQsImV4cCI6MjA5MjY0MjUxNH0.cd-E654STXVVMx9sp2vq3DfRzucAaXapdPalvQgDGyw',
  );
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