import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/section_header.dart';
import 'models/meal.dart';
import 'models/meal_food.dart';
import 'models/nutrition_enums.dart';
import 'services/nutrition_service.dart';
import 'widgets/analyzed_food_editor.dart';
import 'widgets/meal_type_selector.dart';

/// Detalle de una comida del historial: abrir, editar (nombre, tipo,
/// alimentos) y eliminar. Devuelve `true` si hubo cambios que exigen
/// refrescar el dashboard.
class MealDetailScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final _service = NutritionService();
  late final TextEditingController _name;
  late List<MealFood> _foods;
  late MealType _type;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.meal.name);
    _type = widget.meal.type;
    _foods = widget.meal.foods.map((f) => f.copy()).toList();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  double get _cal => _foods.fold(0, (s, f) => s + f.calories);
  double get _p => _foods.fold(0, (s, f) => s + f.protein);
  double get _c => _foods.fold(0, (s, f) => s + f.carbs);
  double get _f => _foods.fold(0, (s, f) => s + f.fat);

  Future<void> _save() async {
    if (_foods.isEmpty) {
      _snack('La comida debe tener al menos un alimento.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.updateMeal(
        mealId: widget.meal.id,
        foods: _foods,
        type: _type,
        name: _name.text.trim().isEmpty ? 'Comida' : _name.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Eliminar comida?'),
        content: const Text('Se quitará de tu historial de hoy.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _deleting = true);
    try {
      await _service.deleteMeal(widget.meal.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
      setState(() => _deleting = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar comida'),
        actions: [
          IconButton(
            onPressed: _deleting ? null : _delete,
            icon: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_outline),
            color: AppColors.error,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenX,
                    AppSpacing.md, AppSpacing.screenX, AppSpacing.xxl),
                children: [
                  TextField(
                    controller: _name,
                    style: AppTextStyles.titleLg,
                    decoration:
                        const InputDecoration(labelText: 'Nombre de la comida'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    elevated: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cell('Kcal', _cal.round().toString()),
                        _cell('Proteína', '${_p.round()} g'),
                        _cell('Carbos', '${_c.round()} g'),
                        _cell('Grasa', '${_f.round()} g'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(title: 'Tipo de comida'),
                  MealTypeSelector(
                      selected: _type,
                      onChanged: (t) => setState(() => _type = t)),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Alimentos'),
                  for (final food in _foods)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AnalyzedFoodEditor(
                        key: ValueKey(food),
                        food: food,
                        onChanged: () => setState(() {}),
                        onDelete: () => setState(() => _foods.remove(food)),
                      ),
                    ),
                  AppButton(
                    label: 'Agregar alimento',
                    icon: Icons.add,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => setState(() => _foods.add(MealFood(
                          name: 'Nuevo alimento',
                          grams: 0,
                          calories: 0,
                          protein: 0,
                          carbs: 0,
                          fat: 0,
                        ))),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenX),
              child: AppButton(
                  label: 'Guardar cambios',
                  loading: _saving,
                  onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String label, String value) => Column(
        children: [
          Text(value, style: AppTextStyles.statSm),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.label),
        ],
      );
}
