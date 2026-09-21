import 'package:flutter/material.dart';

/// PulseUp "Dark Premium" palette — boutique gym at night. Elevation is
/// expressed by stepping surface color up + a hairline, not by shadows.
///
/// Contrast (WCAG) is verified: white text must NEVER sit on [accent] or
/// the semantic colors (fails AA at ~2.9:1) — use [onAccent] / [onSuccess]
/// / [onWarning] / [onError], which are near-black.
class AppColors {
  AppColors._();

  // ---- Surfaces -----------------------------------------------------------
  static const bg = Color(0xFF0A0B0E); // base screen background
  static const surface = Color(0xFF1B1E25); // cards, inputs
  static const surfaceHigh = Color(0xFF262A33); // elevated card, sheets, menus

  // ---- Lines ------------------------------------------------------------
  static const hairline = Color(0xFF32363F); // decorative divider / card edge
  static const hairlineStrong = Color(0xFF454A55); // functional input border

  // ---- Text -----------------------------------------------------------
  static const textPrimary = Color(0xFFF6F7F9);
  static const textSecondary = Color(0xFFAEB2BD); // labels, secondary body
  static const textMuted = Color(0xFF888D99); // metadata / timestamps
  static const onLight = Color(0xFF111317); // text on the light QR card

  // ---- Accent (brand orange, refined) -------------------------------
  static const accent = Color(0xFFFF6A2B); // 6.8:1 on bg — fills + accent text
  static const accentPressed = Color(0xFFE05A1E);
  static const accentSoft = Color(0xFF3A2416); // tint behind accent icons/badges
  static const onAccent = Color(0xFF0B0B0D); // 6.3:1 on accent — near-black

  // ---- Semantic -----------------------------------------------------
  static const success = Color(0xFF43D783);
  static const onSuccess = Color(0xFF0B0B0D);
  static const successSoft = Color(0xFF16301F);

  static const warning = Color(0xFFF8C24E);
  static const onWarning = Color(0xFF0B0B0D);
  static const warningSoft = Color(0xFF322817);

  static const error = Color(0xFFFF6363);
  static const onError = Color(0xFF0B0B0D);
  static const errorSoft = Color(0xFF321A1B);

  // ---- Misc -------------------------------------------------------------
  /// Only for genuinely floating elements (nav pill, FAB, bottom sheet).
  static const ambientShadow = Color(0x66000000);

  /// Category tints for the store — desaturated so they don't fight [accent].
  static const tintBlue = Color(0xFF5AA6E8);
  static const tintViolet = Color(0xFF9B84F4);
  static const tintGreen = Color(0xFF4FB87A);

  /// The dark pill nav sits a touch above [bg].
  static const navBackground = Color(0xFF111317);

  // ---- Back-compat aliases (removed screen-by-screen in redesign Phase 5)
  static const primary = accent;
  static const primaryDark = accentPressed;
  static const primarySoft = accentSoft;
  static const textOnDark = textPrimary;
  static const shadow = ambientShadow;

  static const gradient = LinearGradient(
    colors: [accent, accentPressed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Was a warm light mesh; now a near-flat dark wash so un-migrated
  /// screens still read as part of the dark theme.
  static const screenGradient = LinearGradient(
    colors: [bg, bg],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
