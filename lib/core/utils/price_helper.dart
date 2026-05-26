class PriceHelper {
  static double parse(dynamic value) {
    if (value == null) return 0;

    return double.tryParse(
      value.toString()
          .replaceAll('\$', '')
          .replaceAll(',', '')
          .trim(),
    ) ?? 0;
  }
}