import 'package:flutter/material.dart';

import '../../../core/navigation/app_screen.dart';

import '../models/dashboard_workout.dart';

class WorkoutCard
    extends StatelessWidget {
  final DashboardWorkout? workout;

  final Function(AppScreen) onNavigate;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    if (workout == null) {
      return Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: const Color(
            0xFF1E293B,
          ),

          borderRadius:
              BorderRadius.circular(
            24,
          ),
        ),

        child: const Text(
          "No hay rutina activa",

          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00FF88),
            Color(0xFF00C853),
          ],
        ),

        borderRadius:
            BorderRadius.circular(28),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Entrenamiento Actual",

            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            workout!.name,

            style: const TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "${workout!.exercises} ejercicios",

            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Coach ${workout!.trainer}",

            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              onNavigate(
                AppScreen.routines,
              );
            },

            child: const Text(
              "Ver rutina",
            ),
          ),
        ],
      ),
    );
  }
}