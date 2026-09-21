import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Content shell — NOT a real [Scaffold]. Screens hosted inside
/// `HomeScreen` are swapped into its Scaffold body, so this only supplies
/// the [AppColors.bg] fill, a configurable [SafeArea], and the standard
/// horizontal screen padding. The hosting screen owns scrolling and
/// keyboard insets.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final bool safeTop;
  final bool safeBottom;
  final EdgeInsetsGeometry? padding;

  const AppScaffold({
    super.key,
    required this.child,
    this.safeTop = false,
    this.safeBottom = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
          child: child,
        ),
      ),
    );
  }
}
