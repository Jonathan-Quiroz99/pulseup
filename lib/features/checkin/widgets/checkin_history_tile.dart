import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../models/checkin_record.dart';

class CheckinHistoryTile
    extends StatelessWidget {

  final CheckinRecord checkin;

  const CheckinHistoryTile({
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

            Container(

              padding: const EdgeInsets.all(
                AppSpacing.sm,
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
                Icons.login,
                color:
                    theme.colorScheme.primary,
              ),
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
                    checkin.tipo,
                    style:
                        textTheme.titleMedium,
                  ),

                  const SizedBox(
                    height: AppSpacing.xs,
                  ),

                  Text(
                    '${checkin.fecha} • ${checkin.hora}',
                    style:
                        textTheme.bodyMedium,
                  ),

                  const SizedBox(
                    height: AppSpacing.xs,
                  ),

                  Text(
                    checkin.puerta,
                    style:
                        textTheme.bodySmall,
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