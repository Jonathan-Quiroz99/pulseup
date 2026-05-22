import 'workout_exercise.dart';

class WorkoutPlan {
  final String id;
  final String memberId;
  final String name;
  final String description;
  final String trainer;
  final List<WorkoutExercise> exercises;

  WorkoutPlan({
    required this.id,
    required this.memberId,
    required this.name,
    required this.description,
    required this.trainer,
    required this.exercises,
  });

  factory WorkoutPlan.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkoutPlan(
      id: json['id'],
      memberId: json['member_id'],
      name: json['nombre'],
      description: json['descripcion'] ?? '',
      trainer: json['trainer'] ?? '',
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map(
            (e) => WorkoutExercise.fromJson(e),
          )
          .toList(),
    );
  }
}