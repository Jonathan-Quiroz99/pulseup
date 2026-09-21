import 'package:flutter/material.dart';

/// Estimaciones orientativas de composición corporal. NINGUNA es de grado
/// clínico — son heurísticas para dar al usuario un número de referencia y
/// ver su tendencia en el tiempo. No usar para decisiones médicas.
class BodyCalculationsService {
  /// Grasa corporal estimada con la fórmula **RFM** (Relative Fat Mass,
  /// Woolcott & Bergman, 2018). Solo necesita altura, cintura y sexo — sin
  /// medir el cuello — y está validada contra DEXA, así que es bastante más
  /// fiable que la relación cintura/altura "a pelo" (que antes daba números
  /// disparatados y se quedaba pegada al tope de 35 %).
  ///
  ///   Hombres:  RFM = 64 − 20 × (altura / cintura)
  ///   Mujeres:  RFM = 76 − 20 × (altura / cintura)
  static double calculateBodyFat({
    required double waistCm,
    required double heightCm,
    required String gender, // 'male' o 'female'
  }) {
    if (waistCm <= 0 || heightCm <= 0) return 0;
    final base = gender == 'male' ? 64.0 : 76.0;
    final rfm = base - (20 * heightCm / waistCm);
    return double.parse(rfm.clamp(3.0, 65.0).toStringAsFixed(1));
  }

  /// Estima el % de grasa corporal solo con peso, altura, edad y sexo
  /// (fórmula de Deurenberg) — para cuando no se mide la cintura. Menos
  /// precisa que [calculateBodyFat], pero no requiere ninguna cinta métrica.
  static double calculateBodyFatFromBMI({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender, // 'male' o 'female'
  }) {
    final bmi = calculateBMI(weightKg: weightKg, heightCm: heightCm);
    final sex = gender == 'male' ? 1 : 0;

    final bodyFat = (1.20 * bmi) + (0.23 * age) - (10.8 * sex) - 5.4;

    // Clamp amplio: solo para descartar entradas absurdas, no para "corregir"
    // a la gente que legítimamente está fuera del rango típico.
    return double.parse(bodyFat.clamp(3.0, 60.0).toStringAsFixed(1));
  }

  /// Porcentaje de masa muscular estimado a partir del % de grasa.
  /// Aproximación: a menos grasa, más proporción de músculo.
  static double calculateMusclePercentage({
    required double weightKg,
    required double bodyFatPercentage,
  }) {
    // Músculo esquelético ≈ mitad de la masa magra en un adulto medio.
    final leanMass = 100 - bodyFatPercentage;
    final musclePercentage = leanMass * 0.5;

    final clampedValue = musclePercentage.clamp(20.0, 55.0);
    return double.parse(clampedValue.toStringAsFixed(1));
  }

  /// Calcula el IMC
  static double calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Obtiene la categoría de IMC
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    if (bmi < 35) return 'Obesidad I';
    if (bmi < 40) return 'Obesidad II';
    return 'Obesidad III';
  }

  /// Obtiene el color según la categoría de IMC
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}
