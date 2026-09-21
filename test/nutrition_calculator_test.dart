import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/nutrition/models/meal_food.dart';
import 'package:pulseup/features/nutrition/models/nutrition_enums.dart';
import 'package:pulseup/features/nutrition/services/nutrition_calculator.dart';

void main() {
  group('NutritionCalculator (vista previa del perfil)', () {
    test('BMR Mifflin-St Jeor para hombre', () {
      final bmr = NutritionCalculator.bmr(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: Sex.male,
      );
      expect(bmr, 1780); // 800 + 1125 - 150 + 5
    });

    test('BMR Mifflin-St Jeor para mujer', () {
      final bmr = NutritionCalculator.bmr(
        weightKg: 60,
        heightCm: 165,
        age: 28,
        sex: Sex.female,
      );
      expect(bmr, closeTo(1330.25, 0.001));
    });

    test('déficit del 15% para bajar de peso y superávit del 10% para músculo',
        () {
      final base = {
        'weightKg': 75.0,
        'heightCm': 178.0,
        'age': 27,
        'sex': Sex.male,
        'activity': ActivityLevel.moderatelyActive,
      };
      final lose = NutritionCalculator.estimate(
        weightKg: base['weightKg'] as double,
        heightCm: base['heightCm'] as double,
        age: base['age'] as int,
        sex: base['sex'] as Sex,
        activity: base['activity'] as ActivityLevel,
        goal: FitnessGoal.loseWeight,
      );
      final gain = NutritionCalculator.estimate(
        weightKg: base['weightKg'] as double,
        heightCm: base['heightCm'] as double,
        age: base['age'] as int,
        sex: base['sex'] as Sex,
        activity: base['activity'] as ActivityLevel,
        goal: FitnessGoal.gainMuscle,
      );
      expect(lose.calories, lessThan(lose.tdee));
      expect(gain.calories, greaterThan(gain.tdee));
    });

    test('los macros suman aproximadamente las calorías objetivo', () {
      final e = NutritionCalculator.estimate(
        weightKg: 68,
        heightCm: 170,
        age: 24,
        sex: Sex.female,
        activity: ActivityLevel.lightlyActive,
        goal: FitnessGoal.maintain,
      );
      final kcal = e.protein * 4 + e.carbs * 4 + e.fat * 9;
      expect((kcal - e.calories).abs(), lessThanOrEqualTo(25));
    });
  });

  group('MealFood', () {
    test('parsea y recalcula al editar', () {
      final food = MealFood.fromJson({
        'name': 'Arroz',
        'estimatedGrams': 150,
        'calories': 195,
        'protein': 4,
        'carbs': 42,
        'fat': 0.4,
        'confidence': 0.7,
      });
      expect(food.calories, 195);

      // el usuario corrige la porción
      food
        ..grams = 250
        ..calories = 325
        ..carbs = 70;

      final foods = [food];
      final totalCal = foods.fold<double>(0, (s, f) => s + f.calories);
      expect(totalCal, 325);
      expect(food.toJson()['estimatedGrams'], 250);
    });
  });
}
