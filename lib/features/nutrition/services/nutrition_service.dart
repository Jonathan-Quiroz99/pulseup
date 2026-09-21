import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';
import '../../../core/http_helpers.dart';
import '../../auth/user_session.dart';
import '../models/daily_nutrition.dart';
import '../models/meal.dart';
import '../models/meal_analysis.dart';
import '../models/meal_food.dart';
import '../models/nutrition_enums.dart';
import '../models/nutrition_profile.dart';

/// Se lanza cuando la IA no encuentra comida en la foto — la pantalla lo
/// distingue de un error genérico para mostrar el mensaje correcto.
class NoFoodDetectedException implements Exception {
  final List<String> warnings;
  NoFoodDetectedException(this.warnings);
  @override
  String toString() => 'No se detectó comida en la imagen';
}

class NutritionService {
  static const String _base = '${ApiConfig.baseUrl}/api/mobile/nutrition';

  Map<String, String> _authHeaders({bool json = false}) => {
        'Authorization': 'Bearer ${UserSession.token}',
        if (json) 'Content-Type': 'application/json',
      };

  Never _throwFromBody(http.Response res, String fallback) {
    try {
      final data = jsonDecode(res.body);
      throw Exception(data['detail'] ?? data['message'] ?? fallback);
    } on FormatException {
      throw Exception(fallback);
    }
  }

  // -------------------------------------------------------------------------
  // Perfil
  // -------------------------------------------------------------------------

  Future<NutritionProfile> getProfile() async {
    final res = await http.get(
      Uri.parse('$_base/profile'),
      headers: _authHeaders(),
    ).timeout(apiTimeout);
    await checkAuthResponse(res);
    if (res.statusCode != 200) {
      _throwFromBody(res, 'No se pudo cargar tu perfil de nutrición');
    }
    return NutritionProfile.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<NutritionProfile> saveProfile({
    required Sex sex,
    required ActivityLevel activityLevel,
    required FitnessGoal goal,
    double? weightKg,
    double? heightCm,
    int? age,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/profile'),
      headers: _authHeaders(json: true),
      body: jsonEncode({
        'sexo': sex.id,
        'activityLevel': activityLevel.id,
        'goal': goal.id,
        'weightKg': ?weightKg,
        'heightCm': ?heightCm,
        'age': ?age,
      }),
    ).timeout(apiTimeout);
    await checkAuthResponse(res);
    if (res.statusCode != 200) {
      _throwFromBody(res, 'No se pudo guardar tu perfil de nutrición');
    }
    return NutritionProfile.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
  }

  // -------------------------------------------------------------------------
  // Resumen diario / historial
  // -------------------------------------------------------------------------

  Future<DailyNutrition> getToday({DateTime? day}) async {
    final q = day == null
        ? ''
        : '?fecha=${day.toIso8601String().substring(0, 10)}';
    final res = await http.get(
      Uri.parse('$_base/today$q'),
      headers: _authHeaders(),
    ).timeout(apiTimeout);
    await checkAuthResponse(res);
    if (res.statusCode != 200) {
      _throwFromBody(res, 'No se pudo cargar tu resumen de hoy');
    }
    return DailyNutrition.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // -------------------------------------------------------------------------
  // Análisis de foto con IA
  // -------------------------------------------------------------------------

  /// [imageDataUri] debe ser `data:image/jpeg;base64,....`.
  Future<MealAnalysis> analyzeMeal(String imageDataUri) async {
    final http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$_base/analyze'),
            headers: _authHeaders(json: true),
            body: jsonEncode({'imageBase64': imageDataUri}),
          )
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw Exception('El análisis tardó demasiado. Inténtalo de nuevo.');
    }
    await checkAuthResponse(res);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final analysis = MealAnalysis.fromJson(data);
      if (!analysis.foodDetected) {
        throw NoFoodDetectedException(analysis.warnings);
      }
      return analysis;
    }

    if (res.statusCode == 503) {
      // Antes mostraba un mensaje generico fijo, sin importar la razon real
      // que mandaba el backend (deshabilitado a proposito, falta API key,
      // Ollama inalcanzable, etc.) — eso escondia la causa real al
      // diagnosticar por que la funcion no respondia.
      _throwFromBody(
        res,
        'El análisis con IA no está disponible por ahora. Puedes agregar la comida manualmente.',
      );
    }
    if (res.statusCode == 502) {
      _throwFromBody(res, 'No se pudo analizar la imagen. Inténtalo de nuevo.');
    }
    _throwFromBody(res, 'No se pudo analizar la imagen');
  }

  // -------------------------------------------------------------------------
  // Comidas (guardar / editar / borrar)
  // -------------------------------------------------------------------------

  Future<Meal> saveMeal({
    required MealType type,
    required String name,
    required List<MealFood> foods,
    double? confidence,
    String source = 'ai',
    DateTime? consumedAt,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/meals'),
      headers: _authHeaders(json: true),
      body: jsonEncode({
        'mealType': type.id,
        'name': name,
        'foods': foods.map((f) => f.toJson()).toList(),
        'confidence': ?confidence,
        'source': source,
        'consumedAt': ?consumedAt?.toIso8601String().split('.').first,
      }),
    ).timeout(apiTimeout);
    await checkAuthResponse(res);
    if (res.statusCode != 201 && res.statusCode != 200) {
      _throwFromBody(res, 'No se pudo guardar la comida');
    }
    return Meal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Meal> updateMeal({
    required String mealId,
    required List<MealFood> foods,
    MealType? type,
    String? name,
    DateTime? consumedAt,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/meals/$mealId'),
      headers: _authHeaders(json: true),
      body: jsonEncode({
        'foods': foods.map((f) => f.toJson()).toList(),
        'mealType': ?type?.id,
        'name': ?name,
        'consumedAt': ?consumedAt?.toIso8601String().split('.').first,
      }),
    ).timeout(apiTimeout);
    await checkAuthResponse(res);
    if (res.statusCode != 200) {
      _throwFromBody(res, 'No se pudo actualizar la comida');
    }
    return Meal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Meal> getMeal(String mealId) async {
    final res = await http.get(
      Uri.parse('$_base/meals/$mealId'),
      headers: _authHeaders(),
    ).timeout(apiTimeout);
    await checkAuthResponse(res);
    if (res.statusCode != 200) {
      _throwFromBody(res, 'No se pudo cargar la comida');
    }
    return Meal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteMeal(String mealId) async {
    final res = await http.delete(
      Uri.parse('$_base/meals/$mealId'),
      headers: _authHeaders(),
    ).timeout(apiTimeout);
    await checkAuthResponse(res);
    if (res.statusCode != 204 && res.statusCode != 200) {
      _throwFromBody(res, 'No se pudo eliminar la comida');
    }
  }
}
