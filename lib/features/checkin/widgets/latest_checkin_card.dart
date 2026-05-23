import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../models/checkin_record.dart';

class LatestCheckinCard
    extends StatelessWidget {

  final CheckinRecord checkin;

  const LatestCheckinCard({
    super.key,
    required this.checkin,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),

        child: Row(

          children: [

            Icon(
              Icons.history,
              color:
                  theme.colorScheme.primary,
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    'Último acceso',
                    style:
                        textTheme.bodySmall,
                  ),

                  const SizedBox(
                    height: AppSpacing.xs,
                  ),

                  Text(
                    '${checkin.fecha} • ${checkin.hora}',
                    style:
                        textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}