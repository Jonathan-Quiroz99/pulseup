import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/app_chip.dart';
import '../../widgets/ui/section_header.dart';
import 'models/nutrition_enums.dart';
import 'models/nutrition_profile.dart';
import 'services/nutrition_calculator.dart';
import 'services/nutrition_service.dart';
import 'widgets/nutrition_disclaimer.dart';

/// Formulario del perfil de nutrición. Prellena sexo / edad / peso / altura
/// desde los datos que MemberSync ya tiene (Progreso, bienvenida) y solo pide
/// lo que falta (nivel de actividad y objetivo).
class NutritionProfileScreen extends StatefulWidget {
  final NutritionProfile profile;

  const NutritionProfileScreen({super.key, required this.profile});

  @override
  State<NutritionProfileScreen> createState() => _NutritionProfileScreenState();
}

class _NutritionProfileScreenState extends State<NutritionProfileScreen> {
  final _service = NutritionService();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _age = TextEditingController();

  // Mismos rangos que backend/nutrition/calculator.py (MIN/MAX_*). Antes
  // estos campos solo validaban "> 0": un peso de 9999 kg o una edad de 999
  // años se guardaban tal cual (el backend los recortaba en silencio SOLO al
  // calcular BMR/TDEE, sin avisar, y el preview de esta pantalla no aplicaba
  // ese mismo recorte, asi que podia mostrar un numero distinto al que el
  // backend calcularia despues). Ahora se valida el rango real antes de
  // calcular el preview o guardar.
  static const _minAge = 14, _maxAge = 100;
  static const _minWeight = 30.0, _maxWeight = 300.0;
  static const _minHeight = 120.0, _maxHeight = 230.0;

  late Sex _sex;
  late ActivityLevel _activity;
  late FitnessGoal _goal;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    final m = p.memberData;

    _sex = Sex.fromId(p.sex ?? m.sex);
    _activity = ActivityLevel.fromId(p.activityLevel);
    _goal = FitnessGoal.fromId(p.goal);

    final weight = p.weightKg ?? m.weightKg;
    final height = p.heightCm ?? m.heightCm;
    final age = p.age ?? m.age;
    if (weight != null) _weight.text = _fmt(weight);
    if (height != null) _height.text = _fmt(height);
    if (age != null) _age.text = age.toString();
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _age.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.').trim());

  String? _rangeError() {
    final w = _num(_weight);
    final h = _num(_height);
    final a = int.tryParse(_age.text.trim());
    if (w == null || h == null || a == null) {
      return 'Completa peso, altura y edad con valores válidos.';
    }
    if (w < _minWeight || w > _maxWeight) {
      return 'El peso debe estar entre ${_minWeight.toInt()} y ${_maxWeight.toInt()} kg.';
    }
    if (h < _minHeight || h > _maxHeight) {
      return 'La altura debe estar entre ${_minHeight.toInt()} y ${_maxHeight.toInt()} cm.';
    }
    if (a < _minAge || a > _maxAge) {
      return 'La edad debe estar entre $_minAge y $_maxAge años.';
    }
    return null;
  }

  NutritionEstimate? get _preview {
    if (_rangeError() != null) return null;
    final w = _num(_weight)!;
    final h = _num(_height)!;
    final a = int.tryParse(_age.text.trim())!;
    return NutritionCalculator.estimate(
      weightKg: w,
      heightCm: h,
      age: a,
      sex: _sex,
      activity: _activity,
      goal: _goal,
    );
  }

  Future<void> _save() async {
    final rangeError = _rangeError();
    if (rangeError != null) {
      _snack(rangeError);
      return;
    }
    final w = _num(_weight)!;
    final h = _num(_height)!;
    final a = int.tryParse(_age.text.trim())!;

    setState(() => _saving = true);
    try {
      final saved = await _service.saveProfile(
        sex: _sex,
        activityLevel: _activity,
        goal: _goal,
        weightKg: w,
        heightCm: h,
        age: a,
      );
      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final preview = _preview;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de nutrición')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'Usamos tus datos de MemberSync para calcular tus calorías y '
              'macros. Ajusta lo que quieras.',
              style: AppTextStyles.bodySm,
            ),
            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: 'Sexo'),
            Row(
              children: [
                for (final s in Sex.values) ...[
                  AppChip(
                    label: s.label,
                    selected: _sex == s,
                    onTap: () => setState(() => _sex = s),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: 'Datos'),
            Row(
              children: [
                Expanded(child: _numField('Peso (kg)', _weight)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _numField('Altura (cm)', _height)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _numField('Edad', _age, decimal: false),
            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: 'Nivel de actividad'),
            ...ActivityLevel.values.map(_activityTile),
            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: 'Objetivo'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final g in FitnessGoal.values)
                  AppChip(
                    label: g.label,
                    selected: _goal == g,
                    onTap: () => setState(() => _goal = g),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            if (preview != null) ...[
              AppCard(
                elevated: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu objetivo diario', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${preview.calories} kcal', style: AppTextStyles.stat),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Proteína ${preview.protein} g  ·  Carbos ${preview.carbs} g  ·  Grasa ${preview.fat} g',
                      style: AppTextStyles.bodySm,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'BMR ${preview.bmr} · TDEE ${preview.tdee} kcal',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            const NutritionDisclaimer(),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Guardar perfil',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(String label, TextEditingController c, {bool decimal = true}) {
    return TextField(
      controller: c,
      onChanged: (_) => setState(() {}),
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.,]' : r'[0-9]')),
      ],
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _activityTile(ActivityLevel level) {
    final selected = _activity == level;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderColor: selected ? AppColors.accent : null,
        onTap: () => setState(() => _activity = level),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.label, style: AppTextStyles.titleMd),
                  Text(level.description, style: AppTextStyles.label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
