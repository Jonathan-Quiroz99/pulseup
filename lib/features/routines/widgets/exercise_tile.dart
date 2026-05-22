import 'package:flutter/material.dart';

import '../models/workout_exercise.dart';
import 'routine_chip.dart';

class ExerciseTile extends StatelessWidget {
  final WorkoutExercise exercise;

  const ExerciseTile({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            exercise.name,

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,

            children: [
              RoutineChip(
                icon: Icons.repeat,
                text: "${exercise.sets} series",
              ),

              RoutineChip(
                icon: Icons.numbers,
                text: "${exercise.reps} reps",
              ),

              RoutineChip(
                icon: Icons.timer,
                text: "${exercise.rest}s",
              ),

              RoutineChip(
                icon: Icons.sports_gymnastics,
                text: exercise.muscleGroup,
              ),
            ],
          ),
        ],
      ),
    );
  }
}