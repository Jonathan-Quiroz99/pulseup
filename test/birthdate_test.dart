import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/core/birthdate.dart';

void main() {
  final now = DateTime(2026, 11, 14, 15, 30);

  test('rango del selector: 12 a 100 años', () {
    expect(latestBirthdate(now), DateTime(2014, 11, 14));
    expect(earliestBirthdate(now), DateTime(1925, 11, 15));
  });

  test('nacido en 2025 se rechaza', () {
    expect(birthdateError('2025-03-01', now: now), contains('al menos 12'));
  });

  test('bordes de edad', () {
    expect(birthdateError('2014-11-14', now: now), isNull);
    expect(birthdateError('2014-11-15', now: now), isNotNull);
    expect(birthdateError('1925-11-15', now: now), isNull);
    expect(birthdateError('1925-11-14', now: now), isNotNull);
  });

  test('vacío o mal formado', () {
    expect(birthdateError('', now: now), isNotNull);
    expect(birthdateError('14/11/2000', now: now), isNotNull);
    expect(birthdateError('2000-01-01', now: now), isNull);
  });

  test('29 de febrero no truena', () {
    expect(latestBirthdate(DateTime(2028, 2, 29)), DateTime(2016, 2, 29));
    expect(latestBirthdate(DateTime(2027, 2, 28)), DateTime(2015, 2, 28));
    expect(earliestBirthdate(DateTime(2028, 2, 29)), DateTime(1927, 3, 1));
  });
}
