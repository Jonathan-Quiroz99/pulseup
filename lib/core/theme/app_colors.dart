import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF171717);
  static const card = Color(0xFF1E1E1E);

  // Brand
  static const primary = Color(0xFFFF7A00);
  static const primaryDark = Color(0xFFE56700);

  static const gradient = LinearGradient(
    colors: [
      Color(0xFFFF7A00),
      Color(0xFFE56700),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFBDBDBD);
  static const textMuted = Color(0xFF8A8A8A);

  // Borders
  static const border = Color(0xFF2B2B2B);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFFFB300);
  static const error = Color(0xFFFF5252);

  // Misc
  static const shadow = Colors.black26;
}