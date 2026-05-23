import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class ChallengeCard
    extends StatelessWidget {

  final int checkins;

  const ChallengeCard({
    super.key,
    required this.checkins,
  });

  @override
  Widget build(BuildContext context) {

    final textTheme =
        Theme.of(context).textTheme;

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              'Actividad semanal',
              style:
                  textTheme.bodyMedium,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              '$checkins visitas',
              style:
                  textTheme.headlineMedium,
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Text(
              'Sigue manteniendo tu ritmo 🔥',
              style:
                  textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}