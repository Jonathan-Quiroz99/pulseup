class DashboardWorkout {
  final String name;
  final int exercises;
  final String trainer;

  /// "Día 2 — Pierna" si la rutina va por días; vacío si no.
  final String todayLabel;

  /// Ejercicios del día que toca (o de toda la rutina si no va por días).
  final int todayExercises;

  DashboardWorkout({
    required this.name,
    required this.exercises,
    required this.trainer,
    this.todayLabel = '',
    int? todayExercises,
  }) : todayExercises = todayExercises ?? exercises;
}
