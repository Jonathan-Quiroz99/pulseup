import '../../../core/utils/json_parse.dart';
import 'meal_food.dart';
import 'nutrition_enums.dart';

/// Resultado del análisis de la foto por la IA. Todavía NO es una comida
/// guardada — el usuario la confirma o corrige primero.
class MealAnalysis {
  final String mealName;
  final double confidence;
  final bool foodDetected;
  final bool lowConfidence;
  final List<MealFood> foods;
  final List<String> warnings;
  final MealType suggestedMealType;

  const MealAnalysis({
    required this.mealName,
    required this.confidence,
    required this.foodDetected,
    required this.lowConfidence,
    required this.foods,
    required this.warnings,
    required this.suggestedMealType,
  });

  factory MealAnalysis.fromJson(Map<String, dynamic> json) {
    return MealAnalysis(
      mealName: asString(json['mealName'], fallback: 'Comida'),
      confidence: asDouble(json['confidence']),
      foodDetected: json['foodDetected'] == true,
      lowConfidence: json['lowConfidence'] == true,
      foods: (json['foods'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MealFood.fromJson)
          .toList(),
      warnings: (json['warnings'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      suggestedMealType: MealType.fromId(json['suggestedMealType'] as String?),
    );
  }
}
