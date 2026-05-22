import 'package:flutter/material.dart';

class AddMeasurementSheet extends StatelessWidget {
  final TextEditingController weightController;
  final TextEditingController fatController;
  final TextEditingController muscleController;
  final TextEditingController waistController;
  final TextEditingController chestController;
  final TextEditingController armController;
  final TextEditingController notesController;

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
      padding: const EdgeInsets.all(20),

      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            _field(weightController, "Peso"),
            _field(fatController, "Grasa %"),
            _field(muscleController, "Músculo %"),
            _field(waistController, "Cintura"),
            _field(chestController, "Pecho"),
            _field(armController, "Brazo"),

            _field(
              notesController,
              "Notas",
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: onSave,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF00FF88),
                ),

                child: const Text(
                  "Guardar",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),

      child: TextField(
        controller: controller,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          labelText: label,

          labelStyle: const TextStyle(
            color: Colors.white70,
          ),

          filled: true,
          fillColor: const Color(0xFF1E293B),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}