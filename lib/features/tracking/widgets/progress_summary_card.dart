import 'package:flutter/material.dart';

class ProgressSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProgressSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Icon(
              icon,
              color: const Color(0xFF00FF88),
            ),

            const SizedBox(height: 12),

            Text(
              value,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,

              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}