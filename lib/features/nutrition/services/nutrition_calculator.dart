import '../models/nutrition_enums.dart';

/// Cálculo local de calorías/macros para la vista previa del formulario de
/// perfil (el número autoritativo lo calcula y guarda el backend en
/// `backend/nutrition/calculator.py` — estas constantes deben ir a la par).
///
/// La lógica vive aquí, nunca dentro de los widgets.
class NutritionCalculator {
  NutritionCalculator._();

  // ---- Constantes configurables (espejo del backend) ---------------------
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'extremely_active': 1.9,
  };

  static const Map<String, double> goalCalorieAdjustment = {
    'lose_weight': -0.15,
    'maintain': 0.0,
    'gain_muscle': 0.10,
  };

  static const Map<String, double> proteinGramsPerKg = {
    'lose_weight': 2.0,
    'maintain': 1.8,
    'gain_muscle': 2.2,
  };

  static const double fatCalorieFraction = 0.25;
  static const double proteinMaxCalorieFraction = 0.40;
  static const double fatMinCalorieFraction = 0.15;
  static const double kcalPerGProtein = 4;
  static const double kcalPerGCarb = 4;
  static const double kcalPerGFat = 9;

  // ---- Fórmulas ---------------------------------------------------------
  static double bmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required Sex sex,
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return sex == Sex.male ? base + 5 : base - 161;
  }

  static NutritionEstimate estimate({
    required double weightKg,
    required double heightCm,
    required int age,
    required Sex sex,
    required ActivityLevel activity,
    required FitnessGoal goal,
  }) {
    final b = bmr(weightKg: weightKg, heightCm: heightCm, age: age, sex: sex);
    final tdee = b * (activityMultipliers[activity.id] ?? 1.55);
    var calories = tdee * (1 + (goalCalorieAdjustment[goal.id] ?? 0));
    if (calories < b) calories = b;

    // Proteína topada al 40% de kcal, luego grasa, y los carbohidratos son el
    // resto; si el resto es negativo se recorta la grasa (hasta el 15%).
    var proteinKcal = (proteinGramsPerKg[goal.id] ?? 1.8) *
        weightKg *
        kcalPerGProtein;
    proteinKcal = proteinKcal.clamp(0.0, calories * proteinMaxCalorieFraction);
    var fatKcal = calories * fatCalorieFraction;
    var remaining = calories - proteinKcal - fatKcal;
    if (remaining < 0) {
      fatKcal = (fatKcal + remaining).clamp(calories * fatMinCalorieFraction,
          calories);
      remaining = calories - proteinKcal - fatKcal;
    }
    final carbs = remaining < 0 ? 0.0 : remaining / kcalPerGCarb;

    return NutritionEstimate(
      bmr: b.round(),
      tdee: tdee.round(),
      calories: calories.round(),
      protein: (proteinKcal / kcalPerGProtein).round(),
      carbs: carbs.round(),
      fat: (fatKcal / kcalPerGFat).round(),
    );
  }
}

class NutritionEstimate {
  final int bmr;
  final int tdee;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const NutritionEstimate({
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
