import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

import '../auth/user_session.dart';

import 'models/body_measurement.dart';

import 'services/tracking_service.dart';

import 'widgets/add_measurement_sheet.dart';
import 'widgets/measurement_tile.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/tracking_empty_state.dart';

class TrackingScreen
    extends StatefulWidget {

  const TrackingScreen({
    super.key,
  });

  @override
  State<TrackingScreen>
      createState() =>
          _TrackingScreenState();
}

class _TrackingScreenState
    extends State<TrackingScreen> {

  final TrackingService
      _trackingService =
          TrackingService();

  bool _loading = false;

  List<BodyMeasurement>
      _measurements = [];

  final _weightController =
      TextEditingController();

  final _fatController =
      TextEditingController();

  final _muscleController =
      TextEditingController();

  final _waistController =
      TextEditingController();

  final _chestController =
      TextEditingController();

  final _armController =
      TextEditingController();

  final _notesController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    _loadMeasurements();
  }

  @override
  void dispose() {

    _weightController.dispose();

    _fatController.dispose();

    _muscleController.dispose();

    _waistController.dispose();

    _chestController.dispose();

    _armController.dispose();

    _notesController.dispose();

    super.dispose();
  }

  Future<void>
      _loadMeasurements() async {

    final token =
        UserSession.token;

    if (token == null ||
        token.isEmpty) {

      return;
    }

    try {

      setState(() {
        _loading = true;
      });

      final data =
          await _trackingService
              .fetchMeasurements(
        token,
      );

      if (!mounted) return;

      setState(() {
        _measurements = data;
      });

    } catch (e) {

      debugPrint(
        'Tracking Error: $e',
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void>
      _saveMeasurement() async {

    try {

      final token =
          UserSession.token;

      if (token == null) return;

      await _trackingService
          .addMeasurement(

        token: token,

        weightKg: double.parse(
          _weightController.text,
        ),

        bodyFat: double.parse(
          _fatController.text,
        ),

        muscle: double.parse(
          _muscleController.text,
        ),

        waist: double.parse(
          _waistController.text,
        ),

        chest: double.parse(
          _chestController.text,
        ),

        arm: double.parse(
          _armController.text,
        ),

        notes:
            _notesController.text,
      );

      _clearFields();

      if (!mounted) return;

      Navigator.pop(context);

      _loadMeasurements();

    } catch (e) {

      debugPrint(
        'Save Measurement Error: $e',
      );
    }
  }

  void _clearFields() {

    _weightController.clear();

    _fatController.clear();

    _muscleController.clear();

    _waistController.clear();

    _chestController.clear();

    _armController.clear();

    _notesController.clear();
  }

  void _openAddMeasurementSheet() {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor:
          Colors.transparent,

      builder: (_) {

        return Padding(

          padding: EdgeInsets.only(

            bottom:
                MediaQuery.of(context)
                    .viewInsets
                    .bottom,
          ),

          child: AddMeasurementSheet(

            weightController:
                _weightController,

            fatController:
                _fatController,

            muscleController:
                _muscleController,

            waistController:
                _waistController,

            chestController:
                _chestController,

            armController:
                _armController,

            notesController:
                _notesController,

            onSave:
                _saveMeasurement,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {

      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_measurements.isEmpty) {

      return Scaffold(

        floatingActionButton:
            FloatingActionButton(

          onPressed:
              _openAddMeasurementSheet,

          child: const Icon(
            Icons.add,
          ),
        ),

        body:
            const TrackingEmptyState(),
      );
    }

    final latest =
        _measurements.first;

    return Scaffold(

      floatingActionButton:
          FloatingActionButton(

        onPressed:
            _openAddMeasurementSheet,

        child: const Icon(
          Icons.add,
        ),
      ),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),

          child: Column(

            children: [

              Row(

                children: [

                  ProgressSummaryCard(
                    title: 'Peso',
                    value:
                        '${latest.weightKg} kg',
                    icon:
                        Icons.monitor_weight,
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  ProgressSummaryCard(
                    title: 'Grasa',
                    value:
                        '${latest.bodyFat}%',
                    icon: Icons
                        .local_fire_department,
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Row(

                children: [

                  ProgressSummaryCard(
                    title: 'Músculo',
                    value:
                        '${latest.muscle}%',
                    icon:
                        Icons.fitness_center,
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  ProgressSummaryCard(
                    title: 'Cintura',
                    value:
                        '${latest.waist} cm',
                    icon:
                        Icons.straighten,
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.lg,
              ),

              Expanded(

                child:
                    ListView.separated(

                  itemCount:
                      _measurements.length,

                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(
                    height:
                        AppSpacing.sm,
                  ),

                  itemBuilder:
                      (context, index) {

                    return MeasurementTile(
                      measurement:
                          _measurements[
                              index],
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