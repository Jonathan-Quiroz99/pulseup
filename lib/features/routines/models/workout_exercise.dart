import '../../../core/utils/json_parse.dart';

class WorkoutExercise {
  final String id;
  final String name;
  final String muscleGroup;
  final int sets;
  final String reps;
  final int rest;
  /// Sesión a la que pertenece ("Dia 1 — Torso"); vacío en rutinas viejas.
  final String day;
  final String notes;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.rest,
    this.day = '',
    this.notes = '',
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: asString(json['id']),
      name: asString(json['nombre']),
      muscleGroup: asString(json['grupo_muscular']),
      sets: asInt(json['series'], fallback: 3),
      reps: asString(json['repeticiones'], fallback: '10'),
      rest: asInt(json['descanso_seg'], fallback: 60),
      day: asString(json['dia']),
      notes: asString(json['notas']),
    );
  }
}
