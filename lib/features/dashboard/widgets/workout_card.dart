import 'package:flutter/material.dart';

import '../../../core/navigation/app_screen.dart';

import '../../../widgets/custom_card.dart';

class WorkoutCard extends StatelessWidget {

  final Function(AppScreen) onNavigate;

  const WorkoutCard({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {

    return CustomCard(

      gradient: LinearGradient(
        colors: [
          Color(0xFF00FF88),
          Color(0xFF00C853),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            "Entrenamiento de hoy",

            style: TextStyle(
              color: Colors.black,
            ),
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

            onPressed: () {
              onNavigate(
                AppScreen.routines,
              );
            },

            style: ElevatedButton.styleFrom(

              backgroundColor:
                  Colors.black,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),

            child:
                Text("Iniciar entrenamiento"),
          ),
        ],
      ),
    );
  }
}