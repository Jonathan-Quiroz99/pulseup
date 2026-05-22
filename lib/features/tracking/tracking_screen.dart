import 'package:flutter/material.dart';

import '../auth/user_session.dart';

import 'models/body_measurement.dart';

import 'services/tracking_service.dart';

import 'widgets/add_measurement_sheet.dart';
import 'widgets/measurement_tile.dart';
import 'widgets/progress_summary_card.dart';
import 'widgets/tracking_empty_state.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() =>
      _TrackingScreenState();
}

class _TrackingScreenState
    extends State<TrackingScreen> {
  bool loading = false;

  List<BodyMeasurement> measurements = [];

  // CONTROLLERS
  final weightController =
      TextEditingController();

  final fatController =
      TextEditingController();

  final muscleController =
      TextEditingController();

  final waistController =
      TextEditingController();

  final chestController =
      TextEditingController();

  final armController =
      TextEditingController();

  final notesController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMeasurements();
  }

  @override
  void dispose() {
    weightController.dispose();

    fatController.dispose();

    muscleController.dispose();

    waistController.dispose();

    chestController.dispose();

    armController.dispose();

    notesController.dispose();

    super.dispose();
  }

  Future<void> loadMeasurements() async {
    setState(() {
      loading = true;
    });

    try {
      final token = UserSession.token;

      if (token == null || token.isEmpty) {
        return;
      }

      final data = await TrackingService()
          .fetchMeasurements(token);

      if (!mounted) return;

      setState(() {
        measurements = data;
      });
    } catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> saveMeasurement() async {
    try {
      final token = UserSession.token;

      if (token == null) return;

      await TrackingService().addMeasurement(
        token: token,

        weightKg:
            double.parse(weightController.text),

        bodyFat:
            double.parse(fatController.text),

        muscle:
            double.parse(
              muscleController.text,
            ),

        waist:
            double.parse(
              waistController.text,
            ),

        chest:
            double.parse(
              chestController.text,
            ),

        arm:
            double.parse(
              armController.text,
            ),

        notes: notesController.text,
      );

      // LIMPIAR CAMPOS
      weightController.clear();

      fatController.clear();

      muscleController.clear();

      waistController.clear();

      chestController.clear();

      armController.clear();

      notesController.clear();

      if (!mounted) return;

      Navigator.pop(context);

      loadMeasurements();
    } catch (e) {
      print(e);
    }
  }

  void openAddMeasurementSheet() {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

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
                weightController,

            fatController:
                fatController,

            muscleController:
                muscleController,

            waistController:
                waistController,

            chestController:
                chestController,

            armController:
                armController,

            notesController:
                notesController,

            onSave: saveMeasurement,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest =
        measurements.isNotEmpty
            ? measurements.first
            : null;

    return Scaffold(
      backgroundColor:
          const Color(0xFF0F172A),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xFF00FF88),

        onPressed:
            openAddMeasurementSheet,

        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : measurements.isEmpty
              ? const TrackingEmptyState()

              : SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            ProgressSummaryCard(
                              title: "Peso",

                              value:
                                  "${latest!.weightKg} kg",

                              icon:
                                  Icons.monitor_weight,
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            ProgressSummaryCard(
                              title: "Grasa",

                              value:
                                  "${latest.bodyFat}%",

                              icon:
                                  Icons.local_fire_department,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Row(
                          children: [
                            ProgressSummaryCard(
                              title: "Músculo",

                              value:
                                  "${latest.muscle}%",

                              icon:
                                  Icons.fitness_center,
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            ProgressSummaryCard(
                              title: "Cintura",

                              value:
                                  "${latest.waist} cm",

                              icon:
                                  Icons.straighten,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        Expanded(
                          child:
                              ListView.builder(
                            itemCount:
                                measurements
                                    .length,

                            itemBuilder:
                                (
                                  context,
                                  index,
                                ) {
                              return MeasurementTile(
                                measurement:
                                    measurements[
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