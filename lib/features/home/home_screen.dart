import 'package:flutter/material.dart';
import '../routines/routines_screen.dart';
import '../tracking/tracking_screen.dart';
import '../checkin/checkin_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final screens = [
    RoutinesScreen(),
    TrackingScreen(),
    CheckinScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Rutinas"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progreso"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Check-In"),
        ],
      ),
    );
  }
}