import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';

class RoutinesScreen extends StatelessWidget {
  static const List<String> routines = [
    "Pecho + Tríceps",
    "Espalda + Bíceps",
    "Pierna completa",
  ];

  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rutinas")),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: routines.length,
        itemBuilder: (context, index) {
          return CustomCard(
            child: Text(
              routines[index],
              style: TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}
