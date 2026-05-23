import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class AddMeasurementSheet
    extends StatelessWidget {

  final TextEditingController
      weightController;

  final TextEditingController
      fatController;

  final TextEditingController
      muscleController;

  final TextEditingController
      waistController;

  final TextEditingController
      chestController;

  final TextEditingController
      armController;

  final TextEditingController
      notesController;

  final VoidCallback onSave;

  const AddMeasurementSheet({
    super.key,
    required this.weightController,
    required this.fatController,
    required this.muscleController,
    required this.waistController,
    required this.chestController,
    required this.armController,
    required this.notesController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),

      decoration: BoxDecoration(

        color:
            Theme.of(context)
                .scaffoldBackgroundColor,

        borderRadius:
            const BorderRadius.vertical(

          top: Radius.circular(
            AppSpacing.radiusLg,
          ),
        ),
      ),

      child: SingleChildScrollView(

        child: Column(

          mainAxisSize:
              MainAxisSize.min,

          children: [

            _field(
              controller:
                  weightController,
              label: 'Peso',
            ),

            _field(
              controller:
                  fatController,
              label: 'Grasa %',
            ),

            _field(
              controller:
                  muscleController,
              label: 'Músculo %',
            ),

            _field(
              controller:
                  waistController,
              label: 'Cintura',
            ),

            _field(
              controller:
                  chestController,
              label: 'Pecho',
            ),

            _field(
              controller:
                  armController,
              label: 'Brazo',
            ),

            _field(
              controller:
                  notesController,
              label: 'Notas',
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: onSave,

                child: const Text(
                  'Guardar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController
        controller,
    required String label,
  }) {

    return Padding(

      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          hintText: label,
        ),
      ),
    );
  }
}