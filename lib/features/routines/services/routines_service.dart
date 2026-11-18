import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';
import '../../../core/http_helpers.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';

class RoutinesService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<List<WorkoutPlan>> fetchMyWorkouts(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/mobile/me/workouts"),
      headers: {
        "Authorization": "Bearer $token",
      },
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 200) {
      throw Exception("Failed to load workouts");
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((json) => WorkoutPlan.fromJson(json))
        .toList();
  }

  /// Historial de días terminados, del más reciente al más viejo.
  Future<List<WorkoutSession>> fetchSessions(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/mobile/me/workout-sessions"),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 200) {
      throw Exception("No se pudo cargar tu historial de entrenamientos");
    }
    return (jsonDecode(response.body) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(WorkoutSession.fromJson)
        .toList();
  }

  /// "Terminé el Día X": lo guarda en el servidor (cuenta para Progreso).
  Future<WorkoutSession> finishDay(String token, String planId, String day) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/me/workout-sessions"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"plan_id": planId, "dia": day}),
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 201) {
      var msg = "No se pudo guardar tu entrenamiento. Inténtalo de nuevo.";
      try {
        final detail = jsonDecode(response.body)['detail'];
        if (detail is String && detail.isNotEmpty) msg = detail;
      } catch (_) {}
      throw Exception(msg);
    }
    return WorkoutSession.fromJson(jsonDecode(response.body));
  }

  /// Deshace el último "Terminé" (si se presionó por error).
  Future<void> undoDay(String token, String sessionId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/api/mobile/me/workout-sessions/$sessionId"),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 204) {
      throw Exception("No se pudo deshacer");
    }
  }
}