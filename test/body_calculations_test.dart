import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/tracking/services/body_calculations_service.dart';

void main() {
  group('calculateBodyFat (RFM)', () {
    test('hombre 178cm / cintura 85cm ≈ 22 % (no 35 % pegado al tope)', () {
      final bf = BodyCalculationsService.calculateBodyFat(
        waistCm: 85,
        heightCm: 178,
        gender: 'male',
      );
      // 64 - 20*(178/85) = 22.1
      expect(bf, closeTo(22.1, 0.2));
      expect(bf, lessThan(30));
    });

    test('hombre más delgado (cintura 78) da menos grasa', () {
      final lean = BodyCalculationsService.calculateBodyFat(
        waistCm: 78, heightCm: 178, gender: 'male');
      final soft = BodyCalculationsService.calculateBodyFat(
        waistCm: 95, heightCm: 178, gender: 'male');
      expect(lean, lessThan(soft));
      expect(lean, inInclusiveRange(10, 22));
    });

    test('mujer usa base 76', () {
      final bf = BodyCalculationsService.calculateBodyFat(
        waistCm: 80, heightCm: 165, gender: 'female');
      // 76 - 20*(165/80) = 34.75
      expect(bf, closeTo(34.75, 0.3));
    });

    test('entradas inválidas no revientan (cintura 0)', () {
      expect(
        BodyCalculationsService.calculateBodyFat(
            waistCm: 0, heightCm: 178, gender: 'male'),
        0,
      );
    });

    test('clamp a rango sano', () {
      final huge = BodyCalculationsService.calculateBodyFat(
        waistCm: 200, heightCm: 150, gender: 'male');
      expect(huge, lessThanOrEqualTo(65));
      final tiny = BodyCalculationsService.calculateBodyFat(
        waistCm: 50, heightCm: 190, gender: 'male');
      expect(tiny, greaterThanOrEqualTo(3));
    });
  });

  group('calculateMusclePercentage', () {
    test('a menos grasa, más músculo', () {
      final at15 = BodyCalculationsService.calculateMusclePercentage(
        weightKg: 80, bodyFatPercentage: 15);
      final at30 = BodyCalculationsService.calculateMusclePercentage(
        weightKg: 80, bodyFatPercentage: 30);
      expect(at15, greaterThan(at30));
      expect(at15, closeTo(42.5, 0.1)); // (100-15)/2
    });
  });

  group('calculateBMI', () {
    test('82 kg / 1.78 m ≈ 25.9', () {
      expect(
        BodyCalculationsService.calculateBMI(weightKg: 82, heightCm: 178),
        closeTo(25.9, 0.1),
      );
    });
  });
}
