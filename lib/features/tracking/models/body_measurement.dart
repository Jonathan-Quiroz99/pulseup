import '../../../core/utils/json_parse.dart';

class BodyMeasurement {
  final String id;
  final String memberId;
  final String date;
  final double weightKg;
  final double? bodyFat;
  final double? muscle;
  final double? waist;
  final double? hip;
  final double? chest;
  final double? arm;
  final double? heightCm;
  final String notes;

  BodyMeasurement({
    required this.id,
    required this.memberId,
    required this.date,
    required this.weightKg,
    this.bodyFat,
    this.muscle,
    this.waist,
    this.hip,
    this.chest,
    this.arm,
    this.heightCm,
    required this.notes,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: asString(json['id']),
      memberId: asString(json['member_id']),
      date: asString(json['fecha']),
      weightKg: asDouble(json['peso_kg']),
      bodyFat: asDoubleOrNull(json['grasa_pct']),
      muscle: asDoubleOrNull(json['musculo_pct']),
      waist: asDoubleOrNull(json['cintura_cm']),
      hip: asDoubleOrNull(json['cadera_cm']),
      chest: asDoubleOrNull(json['pecho_cm']),
      arm: asDoubleOrNull(json['brazo_cm']),
      heightCm: asDoubleOrNull(json['altura_cm']),
      notes: asString(json['notas']),
    );
  }
}
