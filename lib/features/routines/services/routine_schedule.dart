import 'package:shared_preferences/shared_preferences.dart';

/// Qué día de la rutina toca hoy. Las rutinas del gimnasio son por sesiones
/// ("Día 1, Día 2, Día 3"), no por día de la semana: cada vez que el socio
/// marca un día como terminado se avanza al siguiente y se vuelve a empezar
/// al acabar la vuelta. Se guarda en el teléfono por rutina, así que una
/// rutina nueva arranca en el Día 1.
class RoutineSchedule {
  RoutineSchedule._();

  static String _key(String planId) => 'routine_done_$planId';

  /// Cuántos días lleva completados en esta rutina.
  static Future<int> completedCount(String planId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_key(planId)) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Índice (0..dayCount-1) del día que toca.
  static int todayIndex(int completed, int dayCount) =>
      dayCount <= 0 ? 0 : completed % dayCount;

  /// Marca el día de hoy como hecho; devuelve el nuevo total.
  static Future<int> markDone(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_key(planId)) ?? 0) + 1;
    await prefs.setInt(_key(planId), next);
    return next;
  }

  /// "Día 1 — Torso" -> ("Día 1", "Torso"); "Día A" -> ("Día A", "").
  static (String, String) splitDayName(String day) {
    final i = day.indexOf('—');
    if (i < 0) return (day.trim(), '');
    return (day.substring(0, i).trim(), day.substring(i + 1).trim());
  }
}
