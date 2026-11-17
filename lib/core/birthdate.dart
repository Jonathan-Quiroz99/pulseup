// lib/core/birthdate.dart
//
// Rango de edad aceptado para un socio. Misma regla que el backend de LED GYM
// (backend/schemas/gym.py: MIN_MEMBER_AGE / MAX_MEMBER_AGE) y que el panel web.
// Antes el selector dejaba elegir cualquier fecha hasta hoy, así que alguien
// "nacido en 2025" se registraba sin problema.

const int minMemberAge = 12;
const int maxMemberAge = 100;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Misma fecha de hace [years] años (29-feb -> 28-feb).
DateTime _yearsBefore(DateTime today, int years) {
  final year = today.year - years;
  final lastDay = DateTime(year, today.month + 1, 0).day;
  final day = today.day > lastDay ? lastDay : today.day;
  return DateTime(year, today.month, day);
}

/// Fecha de nacimiento más reciente permitida (quien cumple hoy [minMemberAge]).
DateTime latestBirthdate([DateTime? now]) =>
    _yearsBefore(_dateOnly(now ?? DateTime.now()), minMemberAge);

/// Fecha de nacimiento más antigua permitida (quien cumple [maxMemberAge]).
DateTime earliestBirthdate([DateTime? now]) {
  // Quien ya cumplió maxMemberAge + 1 queda fuera: el día siguiente a esa fecha.
  final out = _yearsBefore(_dateOnly(now ?? DateTime.now()), maxMemberAge + 1);
  return DateTime(out.year, out.month, out.day + 1);
}

String formatBirthdate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Mensaje de error para una fecha `AAAA-MM-DD`, o `null` si es válida.
String? birthdateError(String value, {DateTime? now}) {
  final v = value.trim();
  if (v.isEmpty) return 'Selecciona tu fecha de nacimiento';
  final parsed = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)
      ? DateTime.tryParse(v)
      : null;
  if (parsed == null) return 'La fecha de nacimiento no es válida';
  if (parsed.isAfter(latestBirthdate(now))) {
    return 'Debes tener al menos $minMemberAge años (revisa el año de nacimiento)';
  }
  if (parsed.isBefore(earliestBirthdate(now))) {
    return 'La fecha de nacimiento no es válida (revisa el año)';
  }
  return null;
}
