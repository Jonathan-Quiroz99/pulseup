import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';
//import '../auth/user_session.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardScreen({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            
            SizedBox(height: 4),
            Text("Nivel 3 • 5 días activo 🔥"),


            // 🔥 Tarjeta principal
            CustomCard(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00FF88),
                  Color(0xFF00C853),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Entrenamiento de hoy",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Pecho + Tríceps 💪",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => onNavigate(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Iniciar entrenamiento"),
                  )
                ],
              ),
            ),

            SizedBox(height: 20),

            // 📊 Progreso rápido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat("Peso", "78kg"),
                _stat("Grasa", "18%"),
                _stat("Días", "12"),
              ],
            ),

            SizedBox(height: 20),

            // ⚡ Acciones rápidas
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _action(Icons.qr_code, "Check-in", () => onNavigate(3)),
                _action(Icons.fitness_center, "Rutinas", () => onNavigate(1)),
                _action(Icons.show_chart, "Progreso", () => onNavigate(2)),
                _action(Icons.emoji_events, "Retos", () {}),
              ],
            ),

            SizedBox(height: 20),

            // 🏆 Reto
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Reto activo 🔥"),
                  SizedBox(height: 8),
                  Text("10,000 pasos diarios"),
                  SizedBox(height: 8),
                  LinearProgressIndicator(value: 0.6),
                ],
              ),
            ),
          ],
        ),
      );
    }

  Widget _stat(String title, String value) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      SizedBox(height: 4),
      Text(
        title,
        style: TextStyle(color: Colors.grey),
      ),
    ],
  );
}

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.greenAccent),
            SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}