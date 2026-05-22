class BodyMeasurement {
  final String id;
  final String memberId;
  final String date;

  final double weightKg;
  final double bodyFat;
  final double muscle;

  final double waist;
  final double chest;
  final double arm;

  final String notes;

  BodyMeasurement({
    required this.id,
    required this.memberId,
    required this.date,
    required this.weightKg,
    required this.bodyFat,
    required this.muscle,
    required this.waist,
    required this.chest,
    required this.arm,
    required this.notes,
  });

  factory BodyMeasurement.fromJson(
    Map<String, dynamic> json,
  ) {
    return BodyMeasurement(
      id: json['id'],
      memberId: json['member_id'],
      date: json['fecha'],

      weightKg:
          (json['peso_kg'] ?? 0).toDouble(),

      bodyFat:
          (json['grasa_pct'] ?? 0).toDouble(),

      muscle:
          (json['musculo_pct'] ?? 0).toDouble(),

      waist:
          (json['cintura_cm'] ?? 0).toDouble(),

      chest:
          (json['pecho_cm'] ?? 0).toDouble(),

      arm:
          (json['brazo_cm'] ?? 0).toDouble(),

      notes: json['notas'] ?? '',
    );
  }
}