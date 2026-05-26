import '../../routines/models/workout_plan.dart';
import '../../routines/services/routines_service.dart';
import '../../tracking/models/body_measurement.dart';
import '../../tracking/services/tracking_service.dart';
import '../../checkin/models/checkin_record.dart';
import '../../checkin/services/checkin_service.dart';
import '../models/dashboard_stats.dart';
import '../models/dashboard_workout.dart';

class DashboardService {
  Future<DashboardWorkout?> fetchWorkout(String token) async {
    final routines = await RoutinesService().fetchMyWorkouts(token);

    if (routines.isEmpty) {
      return null;
    }

    final workout = routines.first;

    return DashboardWorkout(
      name: workout.name,
      exercises: workout.exercises.length,
      trainer: workout.trainer,
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
      bodyFat: latest.bodyFat,  // Mantiene el valor null si existe
      muscle: latest.muscle,    // Mantiene el valor null si existe
    );
  }

  Future<int> fetchWeeklyCheckins(String token) async {
    final checkins = await CheckinService().fetchMyCheckins(token);
    return checkins.length;
  }
}