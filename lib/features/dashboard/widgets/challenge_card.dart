import 'package:flutter/material.dart';

class ChallengeCard
    extends StatelessWidget {
  final int checkins;

  const ChallengeCard({
    super.key,
    required this.checkins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),

        borderRadius:
            BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Actividad semanal",

            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "$checkins visitas",

            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Sigue manteniendo tu ritmo 🔥",

            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}