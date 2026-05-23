import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../models/dashboard_stats.dart';

class StatsRow
    extends StatelessWidget {

  final DashboardStats? stats;

  const StatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        _StatsCard(
          title: 'Peso',
          value: stats != null
              ? '${stats!.weight}kg'
              : '--',
        ),

        const SizedBox(
          width: AppSpacing.sm,
        ),

        _StatsCard(
          title: 'Grasa',
          value: stats != null
              ? '${stats!.bodyFat}%'
              : '--',
        ),

        const SizedBox(
          width: AppSpacing.sm,
        ),

        _StatsCard(
          title: 'Músculo',
          value: stats != null
              ? '${stats!.muscle}%'
              : '--',
        ),
      ],
    );
  }
}

class _StatsCard
    extends StatelessWidget {

  final String title;
  final String value;

  const _StatsCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    final textTheme =
        Theme.of(context).textTheme;

    return Expanded(

      child: Card(

        child: Padding(

          padding:
              const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
          ),

          child: Column(

            children: [

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
                    textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}