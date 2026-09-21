import '../../../core/utils/json_parse.dart';
import 'meal.dart';
import 'nutrition_targets.dart';

class MacroConsumed {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MacroConsumed({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MacroConsumed.fromJson(Map<String, dynamic> json) => MacroConsumed(
        calories: asDouble(json['calories']),
        protein: asDouble(json['protein']),
        carbs: asDouble(json['carbs']),
        fat: asDouble(json['fat']),
      );
}

/// Estado de nutrición de un día: objetivos + lo consumido + las comidas.
class DailyNutrition {
  final String fecha;
  final bool profileConfigured;
  final NutritionTargets? targets;
  final MacroConsumed consumed;
  final double? remainingCalories;
  final List<Meal> meals;

  const DailyNutrition({
    required this.fecha,
    required this.profileConfigured,
    this.targets,
    required this.consumed,
    this.remainingCalories,
    required this.meals,
  });

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      fecha: asString(json['fecha']),
      profileConfigured: json['profileConfigured'] == true,
      targets: json['targets'] is Map<String, dynamic>
          ? NutritionTargets.fromJson(json['targets'] as Map<String, dynamic>)
          : null,
      consumed: MacroConsumed.fromJson(
        (json['consumed'] as Map<String, dynamic>?) ?? const {},
      ),
      remainingCalories: asDoubleOrNull(json['remainingCalories']),
      meals: (json['meals'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Meal.fromJson)
          .toList(),
    );
  }
}
