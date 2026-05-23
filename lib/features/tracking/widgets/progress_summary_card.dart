import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class ProgressSummaryCard
    extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;

  const ProgressSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return Expanded(

      child: Card(

        child: Padding(

          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Icon(
                icon,
                color:
                    theme.colorScheme.primary,
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Text(
                value,
                style:
                    textTheme.titleLarge,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                title,
                style:
                    textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}