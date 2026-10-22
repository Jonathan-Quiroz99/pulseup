import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/api_config.dart';
import '../../../core/http_helpers.dart';
import '../models/body_measurement.dart';

class TrackingService {
  // Antes estaba hardcodeado a produccion: en dev/staging tracking pegaba a
  // otro backend distinto al de login/perfil. Ahora usa la config unica.
  static String get baseUrl => ApiConfig.baseUrl;

  Future<List<BodyMeasurement>> fetchMeasurements(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/mobile/me/measurements"),
      headers: {
        "Authorization": "Bearer $token",
      },
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

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
    double? waist,
    double? hip,
    double? chest,
    double? arm,
    double? heightCm,
    required String notes,
  }) async {
    final Map<String, dynamic> requestBody = {
      "peso_kg": weightKg,
      "notas": notes,
    };

    if (bodyFat != null) requestBody["grasa_pct"] = bodyFat;
    if (muscle != null) requestBody["musculo_pct"] = muscle;
    if (waist != null) requestBody["cintura_cm"] = waist;
    if (hip != null) requestBody["cadera_cm"] = hip;
    if (chest != null) requestBody["pecho_cm"] = chest;
    if (arm != null) requestBody["brazo_cm"] = arm;
    // El backend acepta altura_cm y la guarda en el perfil del socio
    // (para el historial de IMC). La primera medición ya no se queda sin altura.
    if (heightCm != null) requestBody["altura_cm"] = heightCm;

    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/me/measurements"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    ).timeout(apiTimeout);

    if (kDebugMode) {
      debugPrint('POST measurements -> ${response.statusCode}');
    }

    await checkAuthResponse(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add measurement: ${response.statusCode}");
    }
  }
  
  // Borrar una medición
  Future<void> deleteMeasurement(String token, String measurementId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/api/mobile/me/measurements/$measurementId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete measurement: ${response.statusCode}");
    }
  }

  // Guardar altura del usuario en el backend
  Future<void> saveUserHeight(String token, double heightCm) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/me/height"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "altura_cm": heightCm,
      }),
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to save height");
    }
  }
  
  /// Meta de peso del socio (kg) o null si no ha definido una.
  Future<double?> getWeightGoal(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/mobile/me/weight-goal"),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 200) {
      throw Exception("No se pudo cargar tu meta");
    }
    return (jsonDecode(response.body)['meta_peso_kg'] as num?)?.toDouble();
  }

  /// [goalKg] null borra la meta.
  Future<void> saveWeightGoal(String token, double? goalKg) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/mobile/me/weight-goal"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"meta_peso_kg": goalKg}),
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 200) {
      throw Exception("No se pudo guardar tu meta");
    }
  }

  // Obtener altura del usuario
  Future<double?> getUserHeight(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/mobile/me/height"),
        headers: {
          "Authorization": "Bearer $token",
        },
      ).timeout(apiTimeout);

      await checkAuthResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['altura_cm'] as num?)?.toDouble();
      }
    } catch (e) {
      debugPrint('Error getting height: $e');
    }
    return null;
  }
}