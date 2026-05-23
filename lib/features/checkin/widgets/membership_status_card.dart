import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class MembershipStatusCard
    extends StatelessWidget {

  final String membership;
  final String status;

  const MembershipStatusCard({
    super.key,
    required this.membership,
    required this.status,
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
          AppSpacing.lg,
        ),

        child: Row(

          children: [

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
                  AppSpacing.radiusLg,
                ),
              ),

              child: Icon(
                Icons.workspace_premium,
                color:
                    theme.colorScheme.primary,
              ),
            ),

            const SizedBox(
              width: AppSpacing.md,
            ),

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    membership,
                    style:
                        textTheme.titleLarge,
                  ),

                  const SizedBox(
                    height: AppSpacing.xs,
                  ),

                  Text(
                    status,
                    style:
                        textTheme.bodyLarge,
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