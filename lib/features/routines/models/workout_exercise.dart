class WorkoutExercise {
  final String id;
  final String name;
  final String muscleGroup;
  final int sets;
  final String reps;
  final int rest;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.rest,
  });

  factory WorkoutExercise.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkoutExercise(
      id: json['id'],
      name: json['nombre'],
      muscleGroup: json['grupo_muscular'] ?? '',
      sets: json['series'],
      reps: json['repeticiones'],
      rest: json['descanso_seg'],
    );
  }
}