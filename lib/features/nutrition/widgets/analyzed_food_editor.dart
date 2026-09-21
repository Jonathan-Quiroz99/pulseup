import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/meal_food.dart';

/// Tarjeta editable de un alimento detectado. El usuario puede corregir
/// nombre, gramos, calorías y macros; cada cambio se refleja en el modelo
/// y dispara [onChanged] para recalcular los totales de la comida.
class AnalyzedFoodEditor extends StatefulWidget {
  final MealFood food;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const AnalyzedFoodEditor({
    super.key,
    required this.food,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<AnalyzedFoodEditor> createState() => _AnalyzedFoodEditorState();
}

class _AnalyzedFoodEditorState extends State<AnalyzedFoodEditor> {
  late final TextEditingController _name;
  late final TextEditingController _grams;
  late final TextEditingController _kcal;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;

  @override
  void initState() {
    super.initState();
    final f = widget.food;
    _name = TextEditingController(text: f.name);
    _grams = TextEditingController(text: _fmt(f.grams));
    _kcal = TextEditingController(text: _fmt(f.calories));
    _protein = TextEditingController(text: _fmt(f.protein));
    _carbs = TextEditingController(text: _fmt(f.carbs));
    _fat = TextEditingController(text: _fmt(f.fat));
  }

  @override
  void dispose() {
    _name.dispose();
    _grams.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.').trim()) ?? 0;

  void _pushToModel() {
    widget.food
      ..name = _name.text.trim().isEmpty ? 'Alimento' : _name.text.trim()
      ..grams = _num(_grams)
      ..calories = _num(_kcal)
      ..protein = _num(_protein)
      ..carbs = _num(_carbs)
      ..fat = _num(_fat);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  onChanged: (_) => _pushToModel(),
                  style: AppTextStyles.titleMd,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Nombre del alimento',
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textMuted,
                tooltip: 'Quitar',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _field('Gramos', _grams),
              const SizedBox(width: AppSpacing.sm),
              _field('Kcal', _kcal),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _field('Proteína', _protein),
              const SizedBox(width: AppSpacing.sm),
              _field('Carbos', _carbs),
              const SizedBox(width: AppSpacing.sm),
              _field('Grasa', _fat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        onChanged: (_) => _pushToModel(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        style: AppTextStyles.body,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }
}
