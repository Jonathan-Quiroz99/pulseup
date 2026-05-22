import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/workout_plan.dart';

class RoutinesService {
  static const String baseUrl =
      "https://membersync-byso.onrender.com";

  Future<List<WorkoutPlan>> fetchMyWorkouts(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/mobile/me/workouts"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

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