import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';
import '../../../core/http_helpers.dart';
import '../models/workout_plan.dart';

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
}