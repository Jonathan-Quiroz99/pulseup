import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/body_measurement.dart';

class TrackingService {
  static const String baseUrl =
      "https://membersync-byso.onrender.com";

  Future<List<BodyMeasurement>>
      fetchMeasurements(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/mobile/me/measurements",
      ),

      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load measurements",
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map(
          (json) =>
              BodyMeasurement.fromJson(json),
        )
        .toList();
  }

  Future<void> addMeasurement({
  required String token,
  required double weightKg,
  required double bodyFat,
  required double muscle,
  required double waist,
  required double chest,
  required double arm,
  required String notes,
}) async {
  final response = await http.post(
    Uri.parse(
      "$baseUrl/api/mobile/me/measurements",
    ),

    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },

    body: jsonEncode({
      "peso_kg": weightKg,
      "grasa_pct": bodyFat,
      "musculo_pct": muscle,
      "cintura_cm": waist,
      "pecho_cm": chest,
      "brazo_cm": arm,
      "notas": notes,
    }),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 201) {
    throw Exception(
      "Failed to add measurement",
    );
  }
}
}