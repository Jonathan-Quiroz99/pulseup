import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type system for PulseUp. Plus Jakarta Sans carries display/titles
/// (confident, geometric); Inter carries body/data (built for dense
/// numbers). Both are bundled variable fonts (see pubspec `fonts:`) so
/// there's no runtime fetch and the app works offline.
/// [stat] / [statSm] use tabular figures so columns of kg / % / counts
/// line up.
class AppTextStyles {
  AppTextStyles._();

  static const _display = 'PlusJakartaSans';
  static const _body = 'Inter';

  static const displayLg = TextStyle(
    fontFamily: _display,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static const displayMd = TextStyle(
    fontFamily: _display,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const titleLg = TextStyle(
    fontFamily: _display,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const titleMd = TextStyle(
    fontFamily: _display,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const bodySm = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  static const stat = TextStyle(
    fontFamily: _display,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.0,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const statSm = TextStyle(
    fontFamily: _display,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Maps our scale onto Material's [TextTheme] so stock widgets inherit it.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLg,
    displayMedium: displayMd,
    headlineLarge: displayMd,
    headlineMedium: titleLg,
    headlineSmall: titleLg,
    titleLarge: titleLg,
    titleMedium: titleMd,
    titleSmall: titleMd,
    bodyLarge: body,
    bodyMedium: bodySm,
    bodySmall: label,
    labelLarge: titleMd,
    labelMedium: label,
    labelSmall: label,
  );
}
