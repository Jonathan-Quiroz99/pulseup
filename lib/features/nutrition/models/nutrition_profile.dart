import '../../../core/utils/json_parse.dart';
import 'nutrition_targets.dart';

/// Datos que MemberSync ya conoce del socio (edad, altura, peso, grasa,
/// músculo). Se usan para prellenar el formulario y no pedir nada dos veces.
class MemberNutritionData {
  final int? age;
  final double? heightCm;
  final String? sex;
  final double? weightKg;
  final double? bodyFatPct;
  final double? musclePct;

  const MemberNutritionData({
    this.age,
    this.heightCm,
    this.sex,
    this.weightKg,
    this.bodyFatPct,
    this.musclePct,
  });

  factory MemberNutritionData.fromJson(Map<String, dynamic> json) {
    return MemberNutritionData(
      age: json['age'] == null ? null : asInt(json['age']),
      heightCm: asDoubleOrNull(json['heightCm']),
      sex: json['sexo'] as String?,
      weightKg: asDoubleOrNull(json['weightKg']),
      bodyFatPct: asDoubleOrNull(json['bodyFatPct']),
      musclePct: asDoubleOrNull(json['musclePct']),
    );
  }
}

class NutritionProfile {
  final bool configured;
  final String? sex; // 'male' | 'female'
  final String? activityLevel;
  final String? goal;
  final double? weightKg;
  final double? heightCm;
  final int? age;
  final NutritionTargets? targets;
  final MemberNutritionData memberData;
  final List<String> missing;

  const NutritionProfile({
    required this.configured,
    this.sex,
    this.activityLevel,
    this.goal,
    this.weightKg,
    this.heightCm,
    this.age,
    this.targets,
    required this.memberData,
    this.missing = const [],
  });

  factory NutritionProfile.fromJson(Map<String, dynamic> json) {
    return NutritionProfile(
      configured: json['configured'] == true,
      sex: json['sexo'] as String?,
      activityLevel: json['activityLevel'] as String?,
      goal: json['goal'] as String?,
      weightKg: asDoubleOrNull(json['weightKg']),
      heightCm: asDoubleOrNull(json['heightCm']),
      age: json['age'] == null ? null : asInt(json['age']),
      targets: json['targets'] is Map<String, dynamic>
          ? NutritionTargets.fromJson(json['targets'] as Map<String, dynamic>)
          : null,
      memberData: MemberNutritionData.fromJson(
        (json['memberData'] as Map<String, dynamic>?) ?? const {},
      ),
      missing: (json['missing'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
