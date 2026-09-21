import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class StoreHeader extends StatelessWidget {
  final String title;

  const StoreHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenX,
        AppSpacing.sm,
        AppSpacing.screenX,
        AppSpacing.md,
      ),
      child: Text(title, style: AppTextStyles.displayMd),
    );
  }
}
