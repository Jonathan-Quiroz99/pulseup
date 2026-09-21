import '../../../core/utils/json_parse.dart';
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

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: asString(json['id']),
      memberId: asString(json['member_id']),
      name: asString(json['nombre']),
      description: asString(json['descripcion']),
      // El backend manda el nombre ya resuelto en "trainer_nombre" (no hay
      // campo "trainer"); si viniera vacio (plan sin entrenador asignado)
      // no mostramos el id crudo.
      trainer: asString(json['trainer_nombre']),
      // El backend llama a la lista de ejercicios "ejercicios", no
      // "exercises" — con la llave equivocada esto siempre quedaba vacio.
      exercises: (json['ejercicios'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(WorkoutExercise.fromJson)
          .toList(),
    );
  }
}
