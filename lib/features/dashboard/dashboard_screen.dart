import 'package:flutter/material.dart';

import '../../core/navigation/app_screen.dart';

import 'widgets/workout_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/challenge_card.dart';

class DashboardScreen extends StatelessWidget {

  final Function(AppScreen) onNavigate;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(

      padding: EdgeInsets.all(16),

      child: Column(
        children: [

          // 💪 Entrenamiento
          WorkoutCard(
            onNavigate: onNavigate,
          ),

          SizedBox(height: 20),

          // 📊 Stats
          StatsRow(),

          SizedBox(height: 20),

          // ⚡ Acciones rápidas
          QuickActionsGrid(
            onNavigate: onNavigate,
          ),

          SizedBox(height: 20),

          // 🏆 Reto
          ChallengeCard(),
        ],
      ),
    );
  }
}