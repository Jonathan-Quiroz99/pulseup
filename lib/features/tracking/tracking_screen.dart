import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/section_header.dart';
import '../auth/user_session.dart';
import 'models/body_measurement.dart';
import 'services/tracking_service.dart';
import 'services/body_calculations_service.dart';
import 'services/progress_insights.dart';
import 'widgets/dynamic_add_measurement_sheet.dart';
import 'widgets/goal_card.dart';
import 'widgets/measurement_tile.dart';
import 'widgets/metric_line_chart.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/tracking_empty_state.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TrackingService _trackingService = TrackingService();
  final ApiService _apiService = ApiService();
  bool _loading = false;
  List<BodyMeasurement> _measurements = [];
  double? _userHeight;
  int? _userAge;
  String _userGender = 'male';
  bool _autoCalc = true;
  double? _weightGoal;
  String _metricKey = 'peso';

  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _armController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
    _loadUserData();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final token = UserSession.token;
    if (token == null) return;
    try {
      final goal = await _trackingService.getWeightGoal(token);
      if (mounted) setState(() => _weightGoal = goal);
    } catch (e) {
      // Sin meta la pantalla funciona igual (muestra "Define tu meta").
      debugPrint('Tracking: goal failed: $e');
    }
  }

  Future<void> _showEditGoalDialog() async {
    final controller = TextEditingController(
      text: _weightGoal?.toStringAsFixed(1) ?? '',
    );
    final formKey = GlobalKey<FormState>();
    // Devuelve el valor nuevo, NaN para "quitar meta" o null si cancela.
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Meta de peso'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Peso meta (kg)',
              hintText: 'Ej: 72',
            ),
            validator: (value) {
              final parsed = _parseNum(value ?? '');
              if (parsed == null) return 'Ingresa un numero valido';
              // Mismo rango que acepta el backend.
              if (parsed < 30 || parsed > 300) return 'Debe estar entre 30 y 300 kg';
              return null;
            },
          ),
        ),
        actions: [
          if (_weightGoal != null)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(double.nan),
              child: const Text('Quitar meta'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.of(dialogContext).pop(_parseNum(controller.text));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final token = UserSession.token;
    if (token == null) return;
    final newGoal = result.isNaN ? null : result;
    try {
      await _trackingService.saveWeightGoal(token, newGoal);
      if (mounted) setState(() => _weightGoal = newGoal);
    } catch (e) {
      _showSnack('No se pudo guardar tu meta. Inténtalo de nuevo.');
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Computes age in whole years from an ISO "YYYY-MM-DD" birthdate string.
  int? _calculateAge(String? birthDateStr) {
    if (birthDateStr == null || birthDateStr.isEmpty) return null;
    final birthDate = DateTime.tryParse(birthDateStr);
    if (birthDate == null) return null;

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age > 0 ? age : null;
  }

  Future<void> _loadUserData() async {
    final token = UserSession.token;
    if (token == null) return;

    // Height and profile load independently — the estimate should still
    // work off whichever one succeeds.
    double? height;
    try {
      height = await _trackingService.getUserHeight(token);
    } catch (e) {
      debugPrint('Tracking: height failed: $e');
    }

    String? birthDate = UserSession.birthDate;
    try {
      final profile = await _apiService.getMemberProfile(token);
      await UserSession.mergeProfile(profile);
      birthDate = profile['fechaNacimiento'] as String? ?? birthDate;
    } catch (e) {
      debugPrint('Tracking: profile failed: $e');
    }

    if (!mounted) return;
    setState(() {
      if (height != null) _userHeight = height;
      _userAge = _calculateAge(birthDate);
    });
  }

  Future<void> _loadMeasurements() async {
    final token = UserSession.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      final data = await _trackingService.fetchMeasurements(token);
      if (!mounted) return;
      setState(() {
        _measurements = data;
      });
    } catch (e) {
      debugPrint('Tracking Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Acepta coma o punto decimal (algunos teclados ponen coma).
  double? _parseNum(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _saveMeasurement() async {
  try {
    final token = UserSession.token;
    if (token == null) return;

    final weight = _parseNum(_weightController.text);
    if (weight == null || weight <= 0) {
      _showSnack('Ingresa un peso válido.');
      return;
    }
    // Cintura, pecho y brazo son opcionales — no todos van a medirse con
    // cinta métrica.
    final waist = _parseNum(_waistController.text);
    final chest = _parseNum(_chestController.text);
    final arm = _parseNum(_armController.text);

    double? bodyFat;
    double? muscle;

    if (_autoCalc && _userHeight != null) {
      if (waist != null) {
        // Más preciso: usa la cintura real.
        bodyFat = BodyCalculationsService.calculateBodyFat(
          waistCm: waist,
          heightCm: _userHeight!,
          gender: _userGender,
        );
      } else if (_userAge != null) {
        // Sin cintura: estimar solo con peso, altura, edad y sexo
        // (fórmula de Deurenberg). Menos preciso, pero no requiere
        // medirse con cinta.
        bodyFat = BodyCalculationsService.calculateBodyFatFromBMI(
          weightKg: weight,
          heightCm: _userHeight!,
          age: _userAge!,
          gender: _userGender,
        );
      }

      if (bodyFat != null) {
        muscle = BodyCalculationsService.calculateMusclePercentage(
          weightKg: weight,
          bodyFatPercentage: bodyFat,
        );
      }
    }

    await _trackingService.addMeasurement(
      token: token,
      weightKg: weight,
      bodyFat: bodyFat,
      muscle: muscle,
      waist: waist,
      chest: chest,
      arm: arm,
      heightCm: _userHeight, // Enviar altura para que la BD calcule IMC
      notes: _notesController.text,
    );

    _clearFields();
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    _loadMeasurements();

    messenger.showSnackBar(
      const SnackBar(content: Text('Medición guardada exitosamente')),
    );
  } catch (e) {
    debugPrint('Save Measurement Error: $e');
    // Si la sesión expiró, checkAuthResponse ya redirige al login; no
    // molestamos con un error encima.
    if (mounted && !e.toString().contains('expir')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la medición. Inténtalo de nuevo.'),
        ),
      );
    }
  }
}

void _showSnack(String msg) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

Future<void> _saveUserHeight(double height) async {
  final token = UserSession.token;
  if (token == null) return;
  
  try {
    await _trackingService.saveUserHeight(token, height);
    if (!mounted) return;
    setState(() {
      _userHeight = height;
    });
  } catch (e) {
    debugPrint('Error guardando altura: $e');
  }
}

Future<void> _showEditHeightDialog() async {
  final controller = TextEditingController(
    text: _userHeight?.toStringAsFixed(0) ?? '',
  );
  final formKey = GlobalKey<FormState>();

  // Antes esto era un TextField sin Form ni validator: se podia guardar
  // "5" cm o "9999" cm (o texto, que simplemente no hacia nada, sin
  // ningun mensaje). Esa altura se usa para calcular IMC/grasa corporal
  // (BodyCalculationsService, que no acota el resultado) — una altura
  // absurda produce un IMC absurdo en la tarjeta de Progreso. Rango
  // igual al que ya usa el backend para nutricion (120-230 cm).
  final newHeight = await showDialog<double>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Altura'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Altura (cm)',
              hintText: 'Ej: 175',
            ),
            validator: (value) {
              final parsed = double.tryParse((value ?? '').trim());
              if (parsed == null) return 'Ingresa un numero valido';
              if (parsed < 120 || parsed > 230) {
                return 'Debe estar entre 120 y 230 cm';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final value = double.tryParse(controller.text.trim());
              Navigator.of(dialogContext).pop(value);
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );

  if (newHeight == null) return;
  await _saveUserHeight(newHeight);
}

void _openAddMeasurementSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DynamicAddMeasurementSheet(
        weightController: _weightController,
        waistController: _waistController,
        chestController: _chestController,
        armController: _armController,
        notesController: _notesController,
        existingHeight: _userHeight,
        existingAge: _userAge,
        initialGender: _userGender,
        onSaveHeight: _saveUserHeight,
        onGenderChanged: (gender) {
          _userGender = gender;
        },
        onAgeChanged: (age) {
          _userAge = age;
        },
        onAutoCalcChanged: (value) {
          _autoCalc = value;
        },
        onSave: _saveMeasurement,
      );
    },
  );
}

  void _clearFields() {
    _weightController.clear();
    _waistController.clear();
    _chestController.clear();
    _armController.clear();
    _notesController.clear();
  }

  Future<void> _deleteMeasurement(BodyMeasurement measurement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar medición?'),
        content: Text(
          'Se eliminará la medición del ${measurement.date}. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final token = UserSession.token;
    if (token == null) return;

    try {
      await _trackingService.deleteMeasurement(token, measurement.id);
      await _loadMeasurements();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  Widget _buildHeightRow() {
    return Row(
      children: [
        const Icon(Icons.height, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Text(
          _userHeight != null
              ? 'Altura ${_userHeight!.toStringAsFixed(0)} cm'
              : 'Altura no registrada',
          style: AppTextStyles.label,
        ),
        const Spacer(),
        TextButton(
          onPressed: _showEditHeightDialog,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: AppTextStyles.label,
          ),
          child: Text(_userHeight != null ? 'Editar' : 'Agregar'),
        ),
      ],
    );
  }

  Widget _fab() {
    return Positioned(
      right: AppSpacing.screenX,
      bottom: AppSpacing.navBarClearance,
      child: FloatingActionButton(
        onPressed: _openAddMeasurementSheet,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        child: const Icon(Icons.add),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_measurements.isEmpty) {
      return AppScaffold(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                AppSpacing.md,
                AppSpacing.screenX,
                0,
              ),
              child: Column(
                children: [
                  _buildHeightRow(),
                  const Expanded(child: TrackingEmptyState()),
                ],
              ),
            ),
            _fab(),
          ],
        ),
      );
    }

    final latest = _measurements.first;

    // The backend doesn't compute/store IMC — derive it locally.
    final latestHeight = latest.heightCm ?? _userHeight;
    final latestImc = latestHeight != null
        ? BodyCalculationsService.calculateBMI(
            weightKg: latest.weightKg,
            heightCm: latestHeight,
          )
        : null;

    final insights = ProgressInsights(_measurements);
    final metrics = insights.availableMetrics();
    final metric = metrics.firstWhere((m) => m.key == _metricKey,
        orElse: () => metrics.isNotEmpty ? metrics.first : ProgressMetric.all.first);
    final points = insights.series(metric);
    final changes = insights.changes(metric);
    final weightMetric = ProgressMetric.all.first;
    final goalProgress = insights.weightGoal(_weightGoal);
    final daysSince = insights.daysSinceLast();

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          ListView(
            // Deja hueco para la barra de nav flotante + el FAB de "＋".
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenX,
              AppSpacing.md,
              AppSpacing.screenX,
              AppSpacing.navBarClearance + 76,
            ),
            children: [
              _buildHeightRow(),
              const SizedBox(height: AppSpacing.lg),
              if (daysSince != null && daysSince >= 7) ...[
                _ReminderBanner(days: daysSince, onAdd: _openAddMeasurementSheet),
                const SizedBox(height: AppSpacing.md),
              ],
              GoalCard(
                progress: goalProgress,
                goal: _weightGoal,
                weeklyRate: insights.weeklyRate(weightMetric),
                onEdit: _showEditGoalDialog,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final m in metrics)
                            Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.sm),
                              child: ChoiceChip(
                                label: Text(m.label),
                                selected: m.key == metric.key,
                                onSelected: (_) => setState(() => _metricKey = m.key),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (points.length >= 2)
                      MetricLineChart(
                        points: points,
                        unit: metric.unit,
                        goal: metric.key == 'peso' ? _weightGoal : null,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Text(
                          'Registra al menos 2 mediciones de ${metric.label.toLowerCase()} para ver tu gráfica.',
                          style: AppTextStyles.bodySm,
                        ),
                      ),
                    if (changes.sinceStart != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _ChangeStat(
                              label: 'Desde el inicio',
                              delta: changes.sinceStart!,
                              unit: metric.unit,
                              good: ProgressInsights.isImprovement(metric, changes.sinceStart!,
                                  weightGoal: _weightGoal, current: points.last.value),
                            ),
                          ),
                          Expanded(
                            child: _ChangeStat(
                              label: 'Desde la anterior',
                              delta: changes.sinceLast!,
                              unit: metric.unit,
                              good: ProgressInsights.isImprovement(metric, changes.sinceLast!,
                                  weightGoal: _weightGoal, current: points.last.value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProgressSummaryCard(
                      title: 'Peso',
                      value: '${latest.weightKg.toStringAsFixed(1)} kg',
                      icon: Icons.monitor_weight_outlined,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ProgressSummaryCard(
                      title: 'Grasa',
                      value: latest.bodyFat != null
                          ? '${latest.bodyFat!.toStringAsFixed(1)}%'
                          : '--',
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProgressSummaryCard(
                      title: 'Músculo',
                      value: latest.muscle != null
                          ? '${latest.muscle!.toStringAsFixed(1)}%'
                          : '--',
                      icon: Icons.fitness_center_outlined,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ProgressSummaryCard(
                      title: 'Cintura',
                      value: latest.waist != null
                          ? '${latest.waist!.toStringAsFixed(1)} cm'
                          : '--',
                      icon: Icons.straighten_outlined,
                    ),
                  ],
                ),
              ),
              if (latestImc != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: BodyCalculationsService.getBMIColor(latestImc)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('IMC', style: AppTextStyles.label),
                      Text(
                        '${latestImc.toStringAsFixed(1)}  ·  ${BodyCalculationsService.getBMICategory(latestImc)}',
                        style: AppTextStyles.titleMd.copyWith(
                          color: BodyCalculationsService.getBMIColor(latestImc),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Historial'),
              for (var i = 0; i < _measurements.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Builder(builder: (_) {
                    final m = _measurements[i];
                    // La lista viene de la más reciente a la más vieja.
                    final prev = i + 1 < _measurements.length ? _measurements[i + 1] : null;
                    final delta = prev == null ? null : m.weightKg - prev.weightKg;
                    return MeasurementTile(
                      measurement: m,
                      onDelete: () => _deleteMeasurement(m),
                      weightDelta: delta,
                      deltaIsGood: delta == null
                          ? null
                          : ProgressInsights.isImprovement(weightMetric, delta,
                              weightGoal: _weightGoal, current: m.weightKg),
                    );
                  }),
                ),
            ],
          ),
          _fab(),
        ],
      ),
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  final int days;
  final VoidCallback onAdd;

  const _ReminderBanner({required this.days, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_repeat_outlined, color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Tu última medición fue hace $days días. Mídete hoy para ver tu avance.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
            ),
          ),
          TextButton(onPressed: onAdd, child: const Text('Medir')),
        ],
      ),
    );
  }
}

class _ChangeStat extends StatelessWidget {
  final String label;
  final double delta;
  final String unit;
  final bool? good;

  const _ChangeStat({required this.label, required this.delta, required this.unit, required this.good});

  @override
  Widget build(BuildContext context) {
    final color = switch (good) {
      true => AppColors.success,
      false => AppColors.warning,
      null => AppColors.textPrimary,
    };
    final sign = delta > 0.04 ? '+' : (delta < -0.04 ? '−' : '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 2),
        Text('$sign${delta.abs().toStringAsFixed(1)} $unit',
            style: AppTextStyles.statSm.copyWith(color: color)),
      ],
    );
  }
}
