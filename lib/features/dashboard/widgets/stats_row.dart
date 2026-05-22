import 'package:flutter/material.dart';

import '../models/dashboard_stats.dart';

class StatsRow extends StatelessWidget {
  final DashboardStats? stats;

  const StatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          "Peso",
          stats != null
              ? "${stats!.weight}kg"
              : "--",
        ),

        const SizedBox(width: 12),

        _buildCard(
          "Grasa",
          stats != null
              ? "${stats!.bodyFat}%"
              : "--",
        ),

        const SizedBox(width: 12),

        _buildCard(
          "Músculo",
          stats != null
              ? "${stats!.muscle}%"
              : "--",
        ),
      ],
    );
  }

  Widget _buildCard(
    String title,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 20,
        ),

        decoration: BoxDecoration(
          color: const Color(
            0xFF1E293B,
          ),

          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),

        child: Column(
          children: [
            Text(
              value,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,

              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}