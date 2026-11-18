import '../../../core/utils/json_parse.dart';

/// Un día de rutina terminado ("Terminé el Día 2"). Lo guarda el servidor:
/// de aquí salen el "Hoy toca" y el historial de entrenamientos en Progreso.
class WorkoutSession {
  final String id;
  final String planId;
  final String planName;

  /// "Día 1 — Torso"; vacío si la rutina no va por días.
  final String day;
  final int dayIndex;
  final int dayCount;
  final int exercises;

  /// Vuelta de la rutina (1 = la primera vez que la recorre completa).
  final int round;

  /// Último día de su vuelta: con este se completó la rutina.
  final bool closesRound;

  /// AAAA-MM-DD (día local del gimnasio).
  final String date;

  const WorkoutSession({
    required this.id,
    required this.planId,
    required this.planName,
    required this.day,
    required this.dayIndex,
    required this.dayCount,
    required this.exercises,
    required this.round,
    required this.closesRound,
    required this.date,
  });

  /// Días de la rutina que llevaba terminados al guardar este (incluido).
  int get completedAfter => (round - 1) * dayCount + dayIndex + 1;

  DateTime? get dateTime => DateTime.tryParse(date);

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: asString(json['id']),
      planId: asString(json['plan_id']),
      planName: asString(json['plan_nombre']),
      day: asString(json['dia']),
      dayIndex: asInt(json['dia_indice']),
      dayCount: asInt(json['dias_total'], fallback: 1),
      exercises: asInt(json['ejercicios']),
      round: asInt(json['vuelta'], fallback: 1),
      closesRound: json['cierra_vuelta'] == true,
      date: asString(json['fecha']),
    );
  }

  static const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

  /// "18 nov".
  String get dateLabel {
    final d = dateTime;
    return d == null ? date : '${d.day} ${_months[d.month - 1]}';
  }
}

/// Resumen del historial para la tarjeta de Progreso.
class WorkoutStats {
  final int total;
  final int thisWeek;
  final int roundsCompleted;
  final int exercises;

  const WorkoutStats({
    required this.total,
    required this.thisWeek,
    required this.roundsCompleted,
    required this.exercises,
  });

  /// "Esta semana" = de lunes a hoy.
  factory WorkoutStats.from(List<WorkoutSession> sessions, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final monday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    return WorkoutStats(
      total: sessions.length,
      thisWeek: sessions.where((s) {
        final d = s.dateTime;
        return d != null && !d.isBefore(monday);
      }).length,
      roundsCompleted: sessions.where((s) => s.closesRound).length,
      exercises: sessions.fold(0, (sum, s) => sum + s.exercises),
    );
  }
}
