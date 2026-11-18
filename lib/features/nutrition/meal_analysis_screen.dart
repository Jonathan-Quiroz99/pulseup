import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/section_header.dart';
import '../onboarding/section_guide.dart';
import 'models/meal_analysis.dart';
import 'models/meal_food.dart';
import 'models/nutrition_enums.dart';
import 'services/nutrition_service.dart';
import 'widgets/analyzed_food_editor.dart';
import 'widgets/meal_type_selector.dart';
import 'widgets/nutrition_disclaimer.dart';

enum _Step { choose, preview, analyzing, result }

/// Flujo completo: elegir foto → previsualizar → analizar con IA →
/// revisar / corregir → guardar en el historial.
///
/// Devuelve `true` con `Navigator.pop` cuando se guardó una comida, para que
/// el dashboard se refresque.
class MealAnalysisScreen extends StatefulWidget {
  const MealAnalysisScreen({super.key});

  @override
  State<MealAnalysisScreen> createState() => _MealAnalysisScreenState();
}

class _MealAnalysisScreenState extends State<MealAnalysisScreen> {
  final _service = NutritionService();
  final _picker = ImagePicker();

  _Step _step = _Step.choose;
  File? _imageFile;
  String? _imageDataUri;
  String? _error;

  // Resultado editable.
  final _nameController = TextEditingController();
  List<MealFood> _foods = [];
  MealType _mealType = MealType.snack;
  double _confidence = 1;
  bool _lowConfidence = false;
  bool _manual = false;
  List<String> _warnings = [];
  bool _saving = false;

  // Mini tutorial (primera vez): qué presionar en cada paso.
  final _cameraKey = GlobalKey();
  final _manualKey = GlobalKey();
  final _foodsKey = GlobalKey();
  final _typeKey = GlobalKey();
  final _saveKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SectionGuide.showIfFirstTime(context, 'nutricion_foto', _chooseGuide);
  }

  List<GuideStep> _chooseGuide() => [
        GuideStep(
          target: _cameraKey,
          icon: Icons.photo_camera_outlined,
          title: 'Tómale foto a tu plato',
          body: 'Presiona aquí y toma la foto desde arriba, con buena luz y '
              'todo el plato a la vista. También puedes elegirla de la galería.',
        ),
        GuideStep(
          target: _manualKey,
          icon: Icons.edit_outlined,
          title: '¿Sin foto?',
          body: 'Escribe los alimentos a mano. Sirve también si la IA no está '
              'disponible.',
        ),
      ];

  List<GuideStep> _resultGuide() => [
        GuideStep(
          target: _foodsKey,
          icon: Icons.restaurant_menu,
          title: 'Revisa lo que detectó la IA',
          body: 'Si una porción no es la correcta, cambia los gramos: las '
              'calorías y macros se ajustan solos. Borra lo que no comiste.',
        ),
        GuideStep(
          target: _typeKey,
          icon: Icons.schedule,
          title: '¿Qué comida es?',
          body: 'Elige desayuno, comida, cena o snack para ordenarla en tu día.',
        ),
        GuideStep(
          target: _saveKey,
          icon: Icons.check_rounded,
          title: 'Guárdala',
          body: 'Presiona "Agregar comida" y se suma a lo que llevas hoy.',
        ),
      ];

  void _showGuideForStep({bool force = false}) {
    final steps = _step == _Step.result ? _resultGuide : _chooseGuide;
    if (force) {
      SectionGuide.show(context, steps());
    } else if (_step == _Step.result) {
      SectionGuide.showIfFirstTime(context, 'nutricion_resultado', steps);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Selección de imagen
  // -------------------------------------------------------------------------

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      final XFile? x = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (x == null) return; // el usuario canceló

      final bytes = await x.readAsBytes();
      if (bytes.lengthInBytes > 12 * 1024 * 1024) {
        setState(() => _error = 'La imagen es demasiado grande. Prueba con otra.');
        return;
      }
      final mime = _mimeFor(x.name);
      setState(() {
        _imageFile = File(x.path);
        _imageDataUri = 'data:$mime;base64,${base64Encode(bytes)}';
        _step = _Step.preview;
      });
    } on PlatformException catch (e) {
      setState(() => _error = _permissionMessage(e.code, source));
    } catch (_) {
      setState(() => _error = 'No se pudo abrir la imagen. Inténtalo de nuevo.');
    }
  }

  String _mimeFor(String name) {
    // image_picker con imageQuality recomprime a JPEG en iOS y Android
    // (incluidas las fotos HEIC), así que en la práctica siempre es JPEG/PNG.
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _permissionMessage(String code, ImageSource source) {
    if (code.contains('denied') || code.contains('permission')) {
      return source == ImageSource.camera
          ? 'Necesitamos permiso de cámara. Actívalo en los ajustes del teléfono.'
          : 'Necesitamos permiso para acceder a tus fotos. Actívalo en los ajustes.';
    }
    return 'No se pudo acceder a la imagen.';
  }

  // -------------------------------------------------------------------------
  // Análisis con IA
  // -------------------------------------------------------------------------

  Future<void> _analyze() async {
    final dataUri = _imageDataUri;
    if (dataUri == null) return;

    setState(() {
      _step = _Step.analyzing;
      _error = null;
    });

    try {
      final MealAnalysis a = await _service.analyzeMeal(dataUri);
      if (!mounted) return;
      setState(() {
        _nameController.text = a.mealName;
        _foods = a.foods.map((f) => f.copy()).toList();
        _mealType = a.suggestedMealType;
        _confidence = a.confidence;
        _lowConfidence = a.lowConfidence;
        _warnings = a.warnings;
        _step = _Step.result;
      });
      _showGuideForStep();
    } on NoFoodDetectedException catch (e) {
      if (!mounted) return;
      setState(() {
        _step = _Step.preview;
        _error = e.warnings.isNotEmpty
            ? e.warnings.first
            : 'No detectamos comida en la foto. Prueba con otra imagen más clara.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = _Step.preview;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // -------------------------------------------------------------------------
  // Totales (se recalculan al editar cualquier alimento)
  // -------------------------------------------------------------------------

  double get _totalCalories => _foods.fold(0, (s, f) => s + f.calories);
  double get _totalProtein => _foods.fold(0, (s, f) => s + f.protein);
  double get _totalCarbs => _foods.fold(0, (s, f) => s + f.carbs);
  double get _totalFat => _foods.fold(0, (s, f) => s + f.fat);

  void _addEmptyFood() {
    setState(() {
      _foods.add(MealFood(
        name: 'Nuevo alimento',
        grams: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      ));
    });
  }

  /// Entrada manual (sin foto): útil si la IA no está disponible o el usuario
  /// prefiere teclear la comida.
  void _startManual() {
    setState(() {
      _nameController.text = '';
      _foods = [
        MealFood(
            name: 'Alimento',
            grams: 0,
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0),
      ];
      _mealType = MealType.snack;
      _confidence = 1;
      _lowConfidence = false;
      _warnings = [];
      _manual = true;
      _step = _Step.result;
      _error = null;
    });
    _showGuideForStep();
  }

  Future<void> _save() async {
    if (_foods.isEmpty) {
      _snack('Agrega al menos un alimento.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.saveMeal(
        type: _mealType,
        name: _nameController.text.trim().isEmpty
            ? 'Comida'
            : _nameController.text.trim(),
        foods: _foods,
        confidence: _manual ? null : _confidence,
        source: _manual ? 'manual' : 'ai',
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

  void _reset() {
    setState(() {
      _step = _Step.choose;
      _imageFile = null;
      _imageDataUri = null;
      _foods = [];
      _warnings = [];
      _manual = false;
      _error = null;
    });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  // -------------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_step) {
          _Step.result => _manual ? 'Nueva comida' : 'Revisar comida',
          _ => 'Analizar comida',
        }),
        actions: [
          if (_step == _Step.choose || _step == _Step.result)
            IconButton(
              tooltip: 'Cómo funciona',
              onPressed: () => _showGuideForStep(force: true),
              icon: const Icon(Icons.help_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: switch (_step) {
          _Step.choose => _chooseView(),
          _Step.preview => _previewView(),
          _Step.analyzing => _analyzingView(),
          _Step.result => _resultView(),
        },
      ),
    );
  }

  Widget _chooseView() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenX),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu,
                color: AppColors.accent, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Toma una foto de tu comida',
              style: AppTextStyles.titleLg, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'La IA identificará los alimentos y estimará calorías y macros. '
            'Podrás corregir todo antes de guardarlo.',
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_error != null) ...[
            _errorBanner(_error!),
            const SizedBox(height: AppSpacing.md),
          ],
          AppButton(
            key: _cameraKey,
            label: 'Tomar foto',
            icon: Icons.photo_camera_outlined,
            onPressed: () => _pick(ImageSource.camera),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Elegir de la galería',
            icon: Icons.photo_library_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => _pick(ImageSource.gallery),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            key: _manualKey,
            label: 'Agregar sin foto',
            icon: Icons.edit_outlined,
            variant: AppButtonVariant.ghost,
            onPressed: _startManual,
          ),
          const Spacer(),
          const NutritionDisclaimer(),
        ],
      ),
    );
  }

  Widget _previewView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenX),
            child: Column(
              children: [
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Image.file(_imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 320),
                  ),
                const SizedBox(height: AppSpacing.md),
                if (_error != null) _errorBanner(_error!),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenX),
          child: Column(
            children: [
              AppButton(label: 'Analizar comida', onPressed: _analyze),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Cambiar foto',
                variant: AppButtonVariant.ghost,
                onPressed: _reset,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _analyzingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text('Analizando tu comida…', style: AppTextStyles.titleMd),
          const SizedBox(height: AppSpacing.xs),
          Text('Esto puede tardar unos segundos.',
              style: AppTextStyles.bodySm),
        ],
      ),
    );
  }

  Widget _resultView() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenX,
              AppSpacing.md,
              AppSpacing.screenX,
              AppSpacing.xxl,
            ),
            children: [
              if (_lowConfidence)
                _warningBanner(
                  'No estamos del todo seguros de las porciones. Revisa los '
                  'alimentos detectados antes de guardar.',
                ),
              for (final w in _warnings)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _warningBanner(w),
                ),

              TextField(
                controller: _nameController,
                style: AppTextStyles.titleLg,
                decoration: const InputDecoration(labelText: 'Nombre de la comida'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Totales en vivo.
              AppCard(
                elevated: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _totalCell('Kcal', _totalCalories.round().toString()),
                    _totalCell('Proteína', '${_totalProtein.round()} g'),
                    _totalCell('Carbos', '${_totalCarbs.round()} g'),
                    _totalCell('Grasa', '${_totalFat.round()} g'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Column(
                key: _typeKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Tipo de comida'),
                  MealTypeSelector(
                    selected: _mealType,
                    onChanged: (t) => setState(() => _mealType = t),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Column(
                key: _foodsKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                      title: _manual ? 'Alimentos' : 'Alimentos detectados'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Si la porción no es la correcta, cambia los gramos: '
                      'calorías y macros se ajustan solos.',
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                ],
              ),
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
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: 'Agregar alimento',
                icon: Icons.add,
                variant: AppButtonVariant.ghost,
                onPressed: _addEmptyFood,
              ),
              const SizedBox(height: AppSpacing.lg),
              const NutritionDisclaimer(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenX),
          child: Column(
            children: [
              AppButton(
                key: _saveKey,
                label: 'Agregar comida',
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: _manual ? 'Cancelar' : 'Analizar otra foto',
                variant: AppButtonVariant.ghost,
                onPressed: _saving ? null : _reset,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _totalCell(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.statSm),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }

  Widget _errorBanner(String text) => _banner(text, AppColors.error,
      AppColors.errorSoft, Icons.error_outline);

  Widget _warningBanner(String text) => _banner(text, AppColors.warning,
      AppColors.warningSoft, Icons.warning_amber_rounded);

  Widget _banner(String text, Color fg, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
