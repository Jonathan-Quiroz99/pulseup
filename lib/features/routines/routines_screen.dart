import 'package:flutter/material.dart';

import '../auth/user_session.dart';

import 'models/workout_plan.dart';
import 'services/routines_service.dart';

import 'widgets/routine_card.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() =>
      _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  bool loading = false;

  List<WorkoutPlan> routines = [];

  @override
  void initState() {
    super.initState();
    loadRoutines();
  }

  Future<void> loadRoutines() async {
    setState(() {
      loading = true;
    });

    try {
      final token = UserSession.token;

      if (token == null || token.isEmpty) {
        return;
      }

      final data = await RoutinesService()
          .fetchMyWorkouts(token);

      setState(() {
        routines = data;
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : routines.isEmpty
              ? const Center(
                  child: Text(
                    "No hay rutinas disponibles",

                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                )

              : ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: routines.length,

                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                      ),

                      child: RoutineCard(
                        routine: routines[index],
                      ),
                    );
                  },
                ),
    );
  }
}