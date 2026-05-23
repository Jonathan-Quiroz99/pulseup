import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class RoutineChip
    extends StatelessWidget {

  final IconData icon;
  final String text;

  const RoutineChip({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),

      decoration: BoxDecoration(

        color:
            theme.colorScheme.surfaceVariant,

        borderRadius:
            BorderRadius.circular(
          AppSpacing.radiusMd,
        ),
      ),

      child: Row(

        mainAxisSize:
            MainAxisSize.min,

        children: [

          Icon(
            icon,
            size: 16,
            color:
                theme.colorScheme.primary,
          ),

          const SizedBox(
            width: AppSpacing.xs,
          ),

          Text(
            text,
            style:
                textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}