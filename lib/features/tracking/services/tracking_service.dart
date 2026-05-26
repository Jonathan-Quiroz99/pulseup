import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/body_measurement.dart';

class TrackingService {
  static const String baseUrl = "https://membersync-byso.onrender.com";

  Future<List<BodyMeasurement>> fetchMeasurements(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/mobile/me/measurements"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load measurements");
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => BodyMeasurement.fromJson(json)).toList();
  }

  Future<void> addMeasurement({
    required String token,
    required double weightKg,
    double? bodyFat,
    double? muscle,
    required double waist,
    double? hip,
    required double chest,
    required double arm,
    double? heightCm,
    required String notes,
  }) async {
    final Map<String, dynamic> requestBody = {
      "peso_kg": weightKg,
      "cintura_cm": waist,
      "pecho_cm": chest,
      "brazo_cm": arm,
      "notas": notes,
    };
    
    if (bodyFat != null) requestBody["grasa_pct"] = bodyFat;
    if (muscle != null) requestBody["musculo_pct"] = muscle;
    if (hip != null) requestBody["cadera_cm"] = hip;
    if (heightCm != null) requestBody["altura_cm"] = heightCm;
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/me/measurements"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add measurement: ${response.statusCode}");
    }
  }
  
  // Método para obtener la altura del usuario
  Future<double?> getUserHeight(String token) async {
    // Por ahora retorna null, implementa según tu API
    return null;
  }
}