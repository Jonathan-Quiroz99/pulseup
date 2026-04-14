import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Text("Bienvenido 🔥",
                  style: Theme.of(context).textTheme.titleLarge),

              SizedBox(height: 20),

              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rutina de hoy"),
                    SizedBox(height: 10),
                    Text("Pecho + Tríceps",
                        style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () {
                  DefaultTabController.of(context);
                },
                child: CustomCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Ir a Rutinas"),
                      Icon(Icons.fitness_center, color: Colors.greenAccent),
                    ],
                  ),
                ),
              ),

              CustomCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Progreso"),
                    Icon(Icons.show_chart, color: Colors.greenAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}