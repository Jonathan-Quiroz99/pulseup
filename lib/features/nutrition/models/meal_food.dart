import '../../../core/utils/json_parse.dart';

/// Un alimento dentro de una comida. Mutable en memoria mientras el usuario
/// edita la estimación de la IA antes de guardar.
class MealFood {
  String? id;
  String name;
  double grams;
  double calories;
  double protein;
  double carbs;
  double fat;
  final double? confidence;

  MealFood({
    this.id,
    required this.name,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.confidence,
  });

  factory MealFood.fromJson(Map<String, dynamic> json) {
    return MealFood(
      id: json['id'] as String?,
      name: asString(json['name'], fallback: 'Alimento'),
      grams: asDouble(json['estimatedGrams']),
      calories: asDouble(json['calories']),
      protein: asDouble(json['protein']),
      carbs: asDouble(json['carbs']),
      fat: asDouble(json['fat']),
      confidence: asDoubleOrNull(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'estimatedGrams': grams,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'confidence': ?confidence,
      };

  MealFood copy() => MealFood(
        id: id,
        name: name,
        grams: grams,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        confidence: confidence,
      );
}
