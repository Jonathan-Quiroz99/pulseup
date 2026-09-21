/// Small defensive parsers for JSON coming off the backend. The API mostly
/// sends the right types, but a single `null` or a number-as-string used to
/// crash a whole `fromJson` (and take the screen down with it). These keep
/// a bad field from doing that.
library;

String asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

double asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? fallback;
}

double? asDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

int asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? fallback;
}

/// Parses a money string like `"$1,200"` or a raw number into a double.
double asMoney(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  final cleaned = value
      .toString()
      .replaceAll(RegExp(r'[^0-9.\-]'), '')
      .trim();
  return double.tryParse(cleaned) ?? fallback;
}
