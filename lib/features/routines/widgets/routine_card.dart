import 'package:flutter/material.dart';

import '../../../widgets/custom_card.dart';

import '../models/workout_plan.dart';
import 'exercise_tile.dart';

class RoutineCard extends StatelessWidget {
  final WorkoutPlan routine;

  const RoutineCard({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: const Color(0x2200FF88),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFF00FF88),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        routine.name,

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        routine.description,

                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.white54,
                ),

                const SizedBox(width: 6),

                Text(
                  "Coach: ${routine.trainer}",

                  style: const TextStyle(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ...routine.exercises.map(
              (exercise) => ExerciseTile(
                exercise: exercise,
              ),
            ),
          ],
        ),
      ),
    );
  }
}