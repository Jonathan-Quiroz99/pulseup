import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

class CustomCard
    extends StatelessWidget {

  final Widget child;

  final EdgeInsets? padding;

  final Gradient? gradient;

  final Color? backgroundColor;

  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final card = Container(

      width: double.infinity,

      padding:
          padding ??
              const EdgeInsets.all(
                AppSpacing.lg,
              ),

      decoration: BoxDecoration(

        gradient: gradient,

        color: gradient == null
            ? backgroundColor ??
                theme.cardTheme.color
            : null,

        borderRadius:
            BorderRadius.circular(
          AppSpacing.radiusLg,
        ),

        boxShadow: [

          BoxShadow(

            color: theme
                    .shadowColor
                    .withValues(alpha: 0.08),

            blurRadius: 10,

            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(

      borderRadius:
          BorderRadius.circular(
        AppSpacing.radiusLg,
      ),

      onTap: onTap,

      child: card,
    );
  }
}