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
///
/// Al cambiar los GRAMOS, calorías y macros se recalculan en proporción
/// (la IA dijo 250 g de pollo y son 180 g -> todo x 0.72). La proporción
/// sale de la densidad por gramo: la de la IA al inicio, y si el usuario
/// corrige a mano una caloría o macro, esa corrección pasa a ser la base.
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

  /// Kcal / proteína / carbos / grasa por gramo. `null` mientras no se sepa
  /// (alimento agregado a mano sin gramos todavía).
  final Map<String, double?> _perGram = {};

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
    _rememberDensities();
  }

  Map<String, TextEditingController> get _nutrients => {
        'kcal': _kcal,
        'protein': _protein,
        'carbs': _carbs,
        'fat': _fat,
      };

  /// Guarda cuánto aporta cada gramo con los valores actuales.
  void _rememberDensities() {
    final grams = _num(_grams);
    if (grams <= 0) return;
    _nutrients.forEach((key, c) => _perGram[key] = _num(c) / grams);
  }

  void _onGramsChanged() {
    final grams = _num(_grams);
    // Campo vacío o 0 mientras escribe: no se borra nada; al escribir los
    // gramos nuevos se recalcula con la densidad guardada.
    if (grams > 0 && _perGram.isNotEmpty) {
      _nutrients.forEach((key, c) {
        final density = _perGram[key];
        if (density != null) c.text = _fmt(_round1(density * grams));
      });
    } else if (grams > 0) {
      // Primera vez que hay gramos (alimento agregado a mano): base nueva.
      _rememberDensities();
    }
    _pushToModel();
  }

  void _onNutrientChanged() {
    // Corrección manual: la nueva proporción manda en los siguientes cambios
    // de gramos.
    _rememberDensities();
    _pushToModel();
  }

  double _round1(double v) => (v * 10).roundToDouble() / 10;

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
              _field('Gramos', _grams, onChanged: _onGramsChanged),
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

  Widget _field(String label, TextEditingController controller,
      {VoidCallback? onChanged}) {
    return Expanded(
      child: TextField(
        controller: controller,
        onChanged: (_) => (onChanged ?? _onNutrientChanged)(),
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
