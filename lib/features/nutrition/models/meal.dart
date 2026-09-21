import '../../../core/utils/json_parse.dart';
import 'meal_food.dart';
import 'nutrition_enums.dart';

class Meal {
  final String id;
  final MealType type;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? confidence;
  final String source; // 'ai' | 'manual'
  final DateTime? consumedAt;
  final List<MealFood> foods;

  const Meal({
    required this.id,
    required this.type,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.confidence,
    required this.source,
    this.consumedAt,
    required this.foods,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: asString(json['id']),
      type: MealType.fromId(json['mealType'] as String?),
      name: asString(json['name'], fallback: 'Comida'),
      calories: asDouble(json['totalCalories']),
      protein: asDouble(json['protein']),
      carbs: asDouble(json['carbs']),
      fat: asDouble(json['fat']),
      confidence: asDoubleOrNull(json['confidence']),
      source: asString(json['source'], fallback: 'ai'),
      consumedAt: DateTime.tryParse(asString(json['consumedAt'])),
      foods: (json['foods'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MealFood.fromJson)
          .toList(),
    );
  }
}
