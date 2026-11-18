/// Qué día de la rutina toca hoy. Las rutinas del gimnasio son por sesiones
/// ("Día 1, Día 2, Día 3"), no por día de la semana: cada vez que el socio
/// marca un día como terminado se avanza al siguiente, y al acabar el último
/// se completa una "vuelta" y se empieza la siguiente en el Día 1.
///
/// Los días terminados los guarda el servidor (`/me/workout-sessions`), no el
/// teléfono: así cuentan para Progreso y no se pierden al cambiar de celular.
class RoutineSchedule {
  RoutineSchedule._();

  /// Índice (0..dayCount-1) del día que toca.
  static int todayIndex(int completed, int dayCount) =>
      dayCount <= 0 ? 0 : completed % dayCount;

  /// Vuelta en curso (1 = la primera).
  static int currentRound(int completed, int dayCount) =>
      dayCount <= 0 ? 1 : completed ~/ dayCount + 1;

  /// "Día 1 — Torso" -> ("Día 1", "Torso"); "Día A" -> ("Día A", "").
  static (String, String) splitDayName(String day) {
    final i = day.indexOf('—');
    if (i < 0) return (day.trim(), '');
    return (day.substring(0, i).trim(), day.substring(i + 1).trim());
  }
}
