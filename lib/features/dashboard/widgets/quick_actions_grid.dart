import 'package:flutter/material.dart';

import '../../../core/navigation/app_screen.dart';

class QuickActionsGrid extends StatelessWidget {

  final Function(AppScreen) onNavigate;

  const QuickActionsGrid({
    super.key,
    required this.onNavigate,
  });

  Widget action(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {

    return GestureDetector(

      onTap: onTap,

      child: AnimatedContainer(

        duration:
            Duration(milliseconds: 150),

        curve: Curves.easeInOut,

        padding: EdgeInsets.all(12),

        decoration: BoxDecoration(

          color: Colors.white10,

          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Column(

          children: [

            Icon(
              icon,
              color: Colors.greenAccent,
            ),

            SizedBox(height: 6),

            Text(
              label,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GridView.count(

      crossAxisCount: 4,

      shrinkWrap: true,

      physics:
          NeverScrollableScrollPhysics(),

      children: [

        action(
          Icons.qr_code,
          "Check-in",

          () => onNavigate(
            AppScreen.checkin,
          ),
        ),

        action(
          Icons.fitness_center,
          "Rutinas",

          () => onNavigate(
            AppScreen.routines,
          ),
        ),

        action(
          Icons.show_chart,
          "Progreso",

          () => onNavigate(
            AppScreen.tracking,
          ),
        ),

        action(
          Icons.credit_card,
          "Cuenta",

          () => onNavigate(
            AppScreen.billing,
          ),
        ),
      ],
    );
  }
}