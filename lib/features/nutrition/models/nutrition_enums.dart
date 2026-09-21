/// Valores canónicos que comparte con el backend
/// (`backend/nutrition/calculator.py` y `schemas/nutrition.py`).
library;

enum ActivityLevel {
  sedentary('sedentary', 'Sedentario', 'Poco o nada de ejercicio'),
  lightlyActive('lightly_active', 'Ligeramente activo', '1-3 días/semana'),
  moderatelyActive(
      'moderately_active', 'Moderadamente activo', '3-5 días/semana'),
  veryActive('very_active', 'Muy activo', '6-7 días/semana'),
  extremelyActive(
      'extremely_active', 'Extremadamente activo', 'Trabajo físico o 2x/día');

  const ActivityLevel(this.id, this.label, this.description);
  final String id;
  final String label;
  final String description;

  static ActivityLevel fromId(String? id) => ActivityLevel.values.firstWhere(
        (e) => e.id == id,
        orElse: () => ActivityLevel.moderatelyActive,
      );
}

enum FitnessGoal {
  loseWeight('lose_weight', 'Bajar de peso'),
  maintain('maintain', 'Mantener peso'),
  gainMuscle('gain_muscle', 'Ganar músculo');

  const FitnessGoal(this.id, this.label);
  final String id;
  final String label;

  static FitnessGoal fromId(String? id) => FitnessGoal.values.firstWhere(
        (e) => e.id == id,
        orElse: () => FitnessGoal.maintain,
      );
}

enum Sex {
  male('male', 'Hombre'),
  female('female', 'Mujer');

  const Sex(this.id, this.label);
  final String id;
  final String label;

  static Sex fromId(String? id) => Sex.values.firstWhere(
        (e) => e.id == id,
        orElse: () => Sex.male,
      );
}

enum MealType {
  breakfast('breakfast', 'Desayuno'),
  lunch('lunch', 'Comida'),
  dinner('dinner', 'Cena'),
  snack('snack', 'Snack');

  const MealType(this.id, this.label);
  final String id;
  final String label;

  static MealType fromId(String? id) => MealType.values.firstWhere(
        (e) => e.id == id,
        orElse: () => MealType.snack,
      );
}
