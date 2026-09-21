import '../../../core/utils/json_parse.dart';

/// Objetivos diarios de calorías y macros. Los calcula el backend
/// (`backend/nutrition/calculator.py`); el cliente solo los muestra.
class NutritionTargets {
  final int bmr;
  final int tdee;
  final int calories;
  final int protein; // g
  final int carbs; // g
  final int fat; // g
  final String goal;
  final String activityLevel;

  const NutritionTargets({
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.goal,
    required this.activityLevel,
  });

  factory NutritionTargets.fromJson(Map<String, dynamic> json) {
    return NutritionTargets(
      bmr: asInt(json['bmr']),
      tdee: asInt(json['tdee']),
      calories: asInt(json['calories']),
      protein: asInt(json['protein']),
      carbs: asInt(json['carbs']),
      fat: asInt(json['fat']),
      goal: asString(json['goal'], fallback: 'maintain'),
      activityLevel:
          asString(json['activityLevel'], fallback: 'moderately_active'),
    );
  }
}
