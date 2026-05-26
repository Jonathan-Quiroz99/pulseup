class BodyMeasurement {
  final String id;
  final String memberId;
  final String date;
  final double weightKg;
  final double? bodyFat;
  final double? muscle;
  final double waist;
  final double? hip;
  final double chest;
  final double arm;
  final double? heightCm;
  final double? imc;
  final String notes;

  BodyMeasurement({
    required this.id,
    required this.memberId,
    required this.date,
    required this.weightKg,
    this.bodyFat,
    this.muscle,
    required this.waist,
    this.hip,
    required this.chest,
    required this.arm,
    this.heightCm,
    this.imc,
    required this.notes,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    print('Parsing measurement: $json'); // Debug
    
    return BodyMeasurement(
      id: json['id']?.toString() ?? '',
      memberId: json['member_id']?.toString() ?? '',
      date: json['fecha']?.toString() ?? '',
      weightKg: (json['peso_kg'] ?? 0).toDouble(),
      bodyFat: json['grasa_pct'] != null ? (json['grasa_pct'] as num).toDouble() : null,
      muscle: json['musculo_pct'] != null ? (json['musculo_pct'] as num).toDouble() : null,
      waist: (json['cintura_cm'] ?? 0).toDouble(),
      hip: json['cadera_cm'] != null ? (json['cadera_cm'] as num).toDouble() : null,
      chest: (json['pecho_cm'] ?? 0).toDouble(),
      arm: (json['brazo_cm'] ?? 0).toDouble(),
      heightCm: json['altura_cm'] != null ? (json['altura_cm'] as num).toDouble() : null,
      imc: json['imc'] != null ? (json['imc'] as num).toDouble() : null, // IMC calculado por BD
      notes: json['notas']?.toString() ?? '',
    );
  }
}