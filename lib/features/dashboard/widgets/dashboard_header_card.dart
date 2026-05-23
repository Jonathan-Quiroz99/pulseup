import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class DashboardHeader
    extends StatelessWidget {

  final String name;

  const DashboardHeader({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return Row(

      children: [

        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                'Bienvenido 👋',
                style:
                    textTheme.bodyMedium,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                name,
                style:
                    textTheme.headlineLarge,
              ),
            ],
          ),
        ),

        Container(

          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),

          decoration: BoxDecoration(

            color: theme
                .colorScheme.primary
                .withOpacity(0.12),

            borderRadius:
                BorderRadius.circular(
              AppSpacing.radiusMd,
            ),
          ),

          child: Icon(
            Icons.fitness_center,
            color:
                theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}