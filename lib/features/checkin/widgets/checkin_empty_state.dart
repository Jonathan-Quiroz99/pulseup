import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class CheckinEmptyState
    extends StatelessWidget {

  const CheckinEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return Center(

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            Icons.qr_code_2,
            size: 80,
            color: theme
                .colorScheme.onSurface
                .withOpacity(0.24),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Text(
            'Aún no hay registros',
            style:
                textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}