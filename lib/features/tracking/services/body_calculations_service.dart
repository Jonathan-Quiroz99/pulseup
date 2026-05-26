import 'dart:math';
import 'package:flutter/material.dart';

class BodyCalculationsService {
  
  /// Calcula el porcentaje de grasa corporal usando el método de la Marina de EE.UU. (adaptado)
  static double calculateBodyFat({
    required double weightKg,
    required double waistCm,
    required double heightCm,
    required String gender, // 'male' o 'female'
  }) {
    double bodyFat;
    
    if (gender == 'male') {
      // Método para hombres: basado en relación cintura-altura
      final waistToHeightRatio = waistCm / heightCm;
      bodyFat = (waistToHeightRatio * 100) - 10;
      
      // Ajustes por rango saludable
      if (bodyFat < 6) bodyFat = 6;
      if (bodyFat > 35) bodyFat = 35;
      
    } else {
      // Método para mujeres
      final waistToHeightRatio = waistCm / heightCm;
      bodyFat = (waistToHeightRatio * 100) - 5;
      
      // Ajustes por rango saludable
      if (bodyFat < 14) bodyFat = 14;
      if (bodyFat > 40) bodyFat = 40;
    }
    
    return double.parse(bodyFat.toStringAsFixed(1));
  }
  
  /// Calcula el porcentaje de masa muscular
  static double calculateMusclePercentage({
    required double weightKg,
    required double bodyFatPercentage,
  }) {
    // Estimación: músculo = peso total - grasa - huesos/órganos (~15-20%)
    final musclePercentage = 50 - (bodyFatPercentage / 2);
    
    // Limitar a rangos realistas
    final clampedValue = musclePercentage.clamp(30.0, 70.0);
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