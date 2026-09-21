import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../widgets/ui/stat_tile.dart';
import '../models/dashboard_stats.dart';

class StatsRow extends StatelessWidget {
  final DashboardStats? stats;

  const StatsRow({super.key, required this.stats});

  static String? _fmt(double? value, String suffix) {
    if (value == null) return null;
    return '${value.toStringAsFixed(1)}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final stats = this.stats;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatTile(
              label: 'Peso',
              value: stats != null ? _fmt(stats.weight, ' kg') : null,
              icon: Icons.monitor_weight_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatTile(
              label: 'Grasa',
              value: _fmt(stats?.bodyFat, '%'),
              icon: Icons.local_fire_department_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: StatTile(
              label: 'Músculo',
              value: _fmt(stats?.muscle, '%'),
              icon: Icons.fitness_center_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
