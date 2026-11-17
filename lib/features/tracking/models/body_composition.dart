import '../../../core/utils/json_parse.dart';

/// Resultado de `POST /api/mobile/nutrition/body-composition`: % de grasa y
/// músculo ESTIMADOS con las medidas (fórmula) + la foto de progreso (IA).
/// Siempre es un rango: ni la foto ni la cinta métrica dan un valor exacto.
class BodyComposition {
  final double bodyFatPct;
  final double bodyFatLow;
  final double bodyFatHigh;
  final double musclePct;
  final double leanMassKg;
  final double fatMassKg;
  final double bmi;
  final double formulaBodyFatPct;

  /// 'cintura' (RFM, más precisa) o 'imc' (sin cintura).
  final String formulaMethod;
  final double? photoBodyFatPct;
  final bool photoUsed;
  final String photoCues;
  final List<String> warnings;

  const BodyComposition({
    required this.bodyFatPct,
    required this.bodyFatLow,
    required this.bodyFatHigh,
    required this.musclePct,
    required this.leanMassKg,
    required this.fatMassKg,
    required this.bmi,
    required this.formulaBodyFatPct,
    required this.formulaMethod,
    required this.photoBodyFatPct,
    required this.photoUsed,
    required this.photoCues,
    required this.warnings,
  });

  factory BodyComposition.fromJson(Map<String, dynamic> json) {
    return BodyComposition(
      bodyFatPct: asDouble(json['bodyFatPct']),
      bodyFatLow: asDouble(json['bodyFatLow']),
      bodyFatHigh: asDouble(json['bodyFatHigh']),
      musclePct: asDouble(json['musclePct']),
      leanMassKg: asDouble(json['leanMassKg']),
      fatMassKg: asDouble(json['fatMassKg']),
      bmi: asDouble(json['bmi']),
      formulaBodyFatPct: asDouble(json['formulaBodyFatPct']),
      formulaMethod: asString(json['formulaMethod'], fallback: 'imc'),
      photoBodyFatPct: asDoubleOrNull(json['photoBodyFatPct']),
      photoUsed: json['photoUsed'] == true,
      photoCues: asString(json['photoCues']),
      warnings: (json['warnings'] as List? ?? const [])
          .map((w) => w.toString())
          .toList(),
    );
  }
}
