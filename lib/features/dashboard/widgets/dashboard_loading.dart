import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Skeleton placeholder shaped like the real dashboard — calmer than a
/// spinner spinning against an empty screen.
class DashboardLoading extends StatelessWidget {
  const DashboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenX,
        vertical: AppSpacing.md,
      ),
      children: const [
        _Bar(height: 20, widthFactor: 0.5),
        SizedBox(height: AppSpacing.lg),
        _Bar(height: 150),
        SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(child: _Bar(height: 92)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _Bar(height: 92)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _Bar(height: 92)),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        _Bar(height: 110),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final double widthFactor;

  const _Bar({required this.height, this.widthFactor = 1});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.hairline),
          ),
        ),
      ),
    );
  }
}
