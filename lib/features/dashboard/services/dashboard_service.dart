import '../../routines/services/routine_schedule.dart';
import '../../routines/services/routines_service.dart';
import '../../routines/widgets/routine_view.dart';
import '../../tracking/services/tracking_service.dart';
import '../../checkin/services/checkin_service.dart';
import '../models/dashboard_stats.dart';
import '../models/dashboard_workout.dart';

class DashboardService {
  Future<DashboardWorkout?> fetchWorkout(String token) async {
    final routines = await RoutinesService().fetchMyWorkouts(token);

    if (routines.isEmpty) {
      return null;
    }

    // La rutina actual; si ninguna esta marcada activa, la mas reciente.
    final workout = routines.firstWhere((r) => r.isActive,
        orElse: () => routines.first);

    // Mismo criterio que la pantalla de Rutinas (RoutineView).
    final days = RoutineView.groupByDay(workout.exercises);
    var todayLabel = '';
    var todayExercises = workout.exercises.length;
    if (days.length > 1) {
      final today = days[RoutineSchedule.todayIndex(workout.completedSessions, days.length)];
      todayLabel = today.key;
      todayExercises = today.value.length;
    }

    return DashboardWorkout(
      name: workout.name,
      exercises: workout.exercises.length,
      trainer: workout.trainer,
      todayLabel: todayLabel,
      todayExercises: todayExercises,
    );
  }

  Future<DashboardStats?> fetchStats(String token) async {
    final measurements = await TrackingService().fetchMeasurements(token);

    if (measurements.isEmpty) {
      return null;
    }

    final latest = measurements.first;

    return DashboardStats(
      weight: latest.weightKg,
      bodyFat: latest.bodyFat,
      muscle: latest.muscle,
    );
  }

  /// Check-ins in the last 7 days (rolling window from now), not the
  /// all-time total. Records whose `fecha` doesn't parse are skipped.
  Future<int> fetchWeeklyCheckins(String token) async {
    final checkins = await CheckinService().fetchMyCheckins(token);
    final cutoff = DateTime.now().subtract(const Duration(days: 7));

    return checkins.where((c) {
      final date = c.date;
      return date != null && date.isAfter(cutoff);
    }).length;
  }
}
