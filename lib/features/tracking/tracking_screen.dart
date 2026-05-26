import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../auth/user_session.dart';
import 'models/body_measurement.dart';
import 'services/tracking_service.dart';
import 'services/body_calculations_service.dart';
import 'widgets/dynamic_add_measurement_sheet.dart';
import 'widgets/measurement_tile.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/tracking_empty_state.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TrackingService _trackingService = TrackingService();
  bool _loading = false;
  List<BodyMeasurement> _measurements = [];
  double? _userHeight;
  String _userGender = 'male';
  
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
  
  Future<void> _loadUserData() async {
    final token = UserSession.token;
    if (token == null) return;
    
    try {
      final height = await _trackingService.getUserHeight(token);
      if (mounted) {
        setState(() {
          _userHeight = height;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadMeasurements() async {
    final token = UserSession.token;
    if (token == null || token.isEmpty) return;

    try {
      setState(() {
        _loading = true;
      });

      final data = await _trackingService.fetchMeasurements(token);
      if (!mounted) return;

      setState(() {
        _measurements = data;
      });
    } catch (e) {
      debugPrint('Tracking Error: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveMeasurement() async {
  try {
    final token = UserSession.token;
    if (token == null) return;
    
    final weight = double.parse(_weightController.text);
    final waist = double.parse(_waistController.text);
    final chest = double.parse(_chestController.text);
    final arm = double.parse(_armController.text);
    
    double? bodyFat;
    double? muscle;
    
    // Si tenemos altura, calcular grasa y músculo
    if (_userHeight != null) {
      bodyFat = BodyCalculationsService.calculateBodyFat(
        weightKg: weight,
        waistCm: waist,
        heightCm: _userHeight!,
        gender: _userGender,
      );
      
      muscle = BodyCalculationsService.calculateMusclePercentage(
        weightKg: weight,
        bodyFatPercentage: bodyFat,
      );
      
      print('Cálculos - Peso: $weight, Cintura: $waist, Altura: $_userHeight');
      print('Grasa calculada: $bodyFat%, Músculo: $muscle%');
    } else {
      print('No hay altura disponible, no se calculan métricas');
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
    Navigator.pop(context);
    _loadMeasurements();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medición guardada exitosamente')),
    );
  } catch (e) {
    debugPrint('Save Measurement Error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }
}

Future<void> _saveUserHeight(double height) async {
  final token = UserSession.token;
  if (token == null) return;
  
  try {
    await _trackingService.saveUserHeight(token, height);
    setState(() {
      _userHeight = height;
    });
    print('Altura guardada: $height cm');
  } catch (e) {
    print('Error guardando altura: $e');
  }
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

  

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_measurements.isEmpty) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddMeasurementSheet,
          child: const Icon(Icons.add),
        ),
        body: const TrackingEmptyState(),
      );
    }

    final latest = _measurements.first;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMeasurementSheet,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  ProgressSummaryCard(
                    title: 'Peso',
                    value: '${latest.weightKg} kg',
                    icon: Icons.monitor_weight,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ProgressSummaryCard(
                    title: 'Grasa',
                    value: latest.bodyFat != null ? '${latest.bodyFat!.toStringAsFixed(1)}%' : '--',
                    icon: Icons.local_fire_department,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  ProgressSummaryCard(
                    title: 'Músculo',
                    value: latest.muscle != null ? '${latest.muscle!.toStringAsFixed(1)}%' : '--',
                    icon: Icons.fitness_center,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ProgressSummaryCard(
                    title: 'Cintura',
                    value: '${latest.waist.toStringAsFixed(1)} cm',
                    icon: Icons.straighten,
                  ),
                ],
              ),
              if (latest.imc != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: BodyCalculationsService.getBMIColor(latest.imc!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('IMC:'),
                      Text(
                        '${latest.imc!.toStringAsFixed(1)} - ${BodyCalculationsService.getBMICategory(latest.imc!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: BodyCalculationsService.getBMIColor(latest.imc!),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: _measurements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return MeasurementTile(
                      measurement: _measurements[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}