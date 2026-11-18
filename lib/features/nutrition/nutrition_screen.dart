import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/empty_state.dart';
import '../../widgets/ui/section_header.dart';
import '../auth/user_session.dart';
import '../onboarding/section_guide.dart';
import 'meal_analysis_screen.dart';
import 'meal_detail_screen.dart';
import 'models/daily_nutrition.dart';
import 'models/meal.dart';
import 'models/nutrition_enums.dart';
import 'models/nutrition_profile.dart';
import 'nutrition_profile_screen.dart';
import 'services/nutrition_service.dart';
import 'widgets/calorie_summary_card.dart';
import 'widgets/meal_history_tile.dart';
import 'widgets/nutrition_disclaimer.dart';

/// Dashboard de nutrición: objetivo diario, botón para analizar una comida
/// y el historial de comidas de hoy.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _service = NutritionService();

  bool _loading = true;
  String? _error;
  DailyNutrition? _daily;
  NutritionProfile? _profile;

  // Mini tutorial de la sección.
  final _summaryKey = GlobalKey();
  final _analyzeKey = GlobalKey();
  final _mealsKey = GlobalKey();
  final _tuneKey = GlobalKey();
  String? _guideShown; // id del tutorial ya revisado en esta pantalla

  @override
  void initState() {
    super.initState();
    SectionGuide.attach(this, () => SectionGuide.show(context, _guideSteps()));
    _load();
  }

  @override
  void dispose() {
    SectionGuide.detach(this);
    super.dispose();
  }

  bool get _configured =>
      _profile?.configured ?? _daily?.profileConfigured ?? false;

  List<GuideStep> _guideSteps() {
    if (_daily == null) return const [];
    if (!_configured) {
      return [
        GuideStep(
          target: _summaryKey,
          icon: Icons.flag_outlined,
          title: 'Primero, tu objetivo',
          body: 'Presiona "Empezar": con tu peso, altura, edad y actividad '
              'calculamos las calorías y macros que necesitas al día.',
        ),
        const GuideStep(
          icon: Icons.photo_camera_outlined,
          title: 'Luego, analiza tu comida con IA',
          body: 'Aparecerá el botón "Analizar comida": tómale foto a tu plato '
              'y la IA estima calorías, proteína, carbos y grasa.',
        ),
        GuideStep(
          target: _mealsKey,
          icon: Icons.restaurant_outlined,
          title: 'Tus comidas de hoy',
          body: 'Aquí se van sumando las comidas que registres en el día.',
        ),
      ];
    }
    return [
      GuideStep(
        target: _summaryKey,
        icon: Icons.local_fire_department_outlined,
        title: 'Tu día en números',
        body: 'Cuántas calorías y macros llevas hoy y cuánto te falta para '
            'tu objetivo.',
      ),
      GuideStep(
        target: _analyzeKey,
        icon: Icons.photo_camera_outlined,
        title: 'Analiza tu comida con IA',
        body: 'Presiona aquí y tómale foto a tu plato. La IA reconoce los '
            'alimentos y estima calorías y macros; tú lo corriges antes de '
            'guardar.',
      ),
      GuideStep(
        target: _mealsKey,
        icon: Icons.restaurant_outlined,
        title: 'Comidas de hoy',
        body: 'Toca una comida para ver el detalle, corregirla o borrarla.',
      ),
      GuideStep(
        target: _tuneKey,
        icon: Icons.tune,
        title: 'Ajusta tu objetivo',
        body: 'Si cambia tu peso o tu meta, recalcula tus calorías aquí.',
      ),
    ];
  }

  /// Sin objetivo se explica cómo configurarlo; ya configurado, el botón de
  /// analizar comida. Son dos tutoriales: el segundo sale al configurarlo.
  void _maybeShowGuide() {
    if (_daily == null) return;
    final id = _configured ? 'nutricion' : 'nutricion_inicio';
    if (_guideShown == id) return;
    _guideShown = id;
    SectionGuide.showIfFirstTime(context, id, _guideSteps);
  }

  Future<void> _load() async {
    if (UserSession.token == null) {
      setState(() => _loading = false);
      return;
    }
    if (!_loading) setState(() => _loading = true);

    try {
      final results = await Future.wait([
        _service.getToday(),
        _service.getProfile(),
      ]);
      if (!mounted) return;
      setState(() {
        _daily = results[0] as DailyNutrition;
        _profile = results[1] as NutritionProfile;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _maybeShowGuide();
      }
    }
  }

  Future<void> _openProfile() async {
    final profile = _profile;
    if (profile == null) return;
    final updated = await Navigator.push<NutritionProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => NutritionProfileScreen(profile: profile),
      ),
    );
    if (updated != null) _load();
  }

  Future<void> _analyzeMeal() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MealAnalysisScreen()),
    );
    if (saved == true) _load();
  }

  Future<void> _openMeal(Meal meal) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _daily == null) {
      return AppScaffold(
        padding: EdgeInsets.zero,
        child: EmptyState(
          icon: Icons.restaurant_outlined,
          title: 'No se pudo cargar nutrición',
          message: _error,
          actionLabel: 'Reintentar',
          onAction: _load,
        ),
      );
    }

    final daily = _daily!;
    final profileConfigured = _profile?.configured ?? daily.profileConfigured;

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollCacheExtent: const ScrollCacheExtent.pixels(3000),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.navBarClearance,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Nutrición', style: AppTextStyles.displayMd),
                ),
                if (profileConfigured)
                  IconButton(
                    key: _tuneKey,
                    onPressed: _openProfile,
                    icon: const Icon(Icons.tune),
                    tooltip: 'Ajustar objetivo',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            if (!profileConfigured)
              KeyedSubtree(key: _summaryKey, child: _setupCard())
            else ...[
              KeyedSubtree(key: _summaryKey, child: CalorieSummaryCard(daily: daily)),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                key: _analyzeKey,
                label: 'Analizar comida',
                icon: Icons.photo_camera_outlined,
                onPressed: _analyzeMeal,
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
            SectionHeader(key: _mealsKey, title: 'Comidas de hoy'),
            if (daily.meals.isEmpty)
              const _NoMeals()
            else
              ..._mealsByType(daily),

            const SizedBox(height: AppSpacing.xl),
            const NutritionDisclaimer(),
          ],
        ),
      ),
    );
  }

  List<Widget> _mealsByType(DailyNutrition daily) {
    final widgets = <Widget>[];
    for (final type in MealType.values) {
      final meals = daily.meals.where((m) => m.type == type).toList();
      if (meals.isEmpty) continue;
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
        child: Text(type.label.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted)),
      ));
      for (final meal in meals) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: MealHistoryTile(meal: meal, onTap: () => _openMeal(meal)),
        ));
      }
    }

    final total = daily.consumed.calories.round();
    final target = daily.targets?.calories;
    widgets.add(Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: AppTextStyles.titleMd),
          Text(
            target != null ? '$total / $target kcal' : '$total kcal',
            style: AppTextStyles.titleMd.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    ));
    return widgets;
  }

  Widget _setupCard() {
    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configura tu objetivo', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Calcula cuántas calorías y macros necesitas al día según tu peso, '
            'altura, edad, nivel de actividad y objetivo.',
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: 'Empezar', onPressed: _openProfile),
        ],
      ),
    );
  }
}

class _NoMeals extends StatelessWidget {
  const _NoMeals();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.restaurant_outlined,
              color: AppColors.textMuted, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Aún no registras comidas hoy. Toca "Analizar comida" para empezar.',
              style: AppTextStyles.bodySm,
            ),
          ),
        ],
      ),
    );
  }
}
