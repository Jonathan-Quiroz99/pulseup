import 'package:flutter/material.dart';

import '../../widgets/custom_card.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  bool loading = false;

  final List<Map<String, dynamic>> routines = [
    {
      "name": "Pecho + Tríceps",
      "description": "Hipertrofia enfocada en fuerza",
      "trainer": "Carlos Mendoza",
      "exercises": [
        {
          "name": "Press banca",
          "sets": 4,
          "reps": "10",
          "rest": 90,
          "muscle": "Pecho",
        },
        {
          "name": "Press inclinado",
          "sets": 4,
          "reps": "12",
          "rest": 60,
          "muscle": "Pecho superior",
        },
        {
          "name": "Fondos",
          "sets": 3,
          "reps": "15",
          "rest": 45,
          "muscle": "Tríceps",
        },
      ]
    },
    {
      "name": "Espalda + Bíceps",
      "description": "Rutina de volumen",
      "trainer": "Ana López",
      "exercises": [
        {
          "name": "Dominadas",
          "sets": 4,
          "reps": "8",
          "rest": 90,
          "muscle": "Espalda",
        },
        {
          "name": "Remo barra",
          "sets": 4,
          "reps": "10",
          "rest": 75,
          "muscle": "Espalda media",
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Color(0xFF0F172A),
                  pinned: true,
                  elevation: 0,
                  title: Text(
                    "Mis Rutinas",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final routine = routines[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomCard(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // HEADER
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Color(0x2200FF88),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.fitness_center,
                                          color: Color(0xFF00FF88),
                                        ),
                                      ),

                                      SizedBox(width: 12),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              routine["name"],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),

                                            SizedBox(height: 4),

                                            Text(
                                              routine["description"],
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 18),

                                  // TRAINER
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Coach: ${routine["trainer"]}",
                                        style: TextStyle(
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 20),

                                  // EXERCISES
                                  ...List.generate(
                                    routine["exercises"].length,
                                    (exerciseIndex) {
                                      final exercise = routine["exercises"]
                                          [exerciseIndex];

                                      return Container(
                                        margin:
                                            EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1E293B),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exercise["name"],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),

                                            SizedBox(height: 10),

                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: [
                                                _buildChip(
                                                  Icons.repeat,
                                                  "${exercise["sets"]} series",
                                                ),

                                                _buildChip(
                                                  Icons.numbers,
                                                  "${exercise["reps"]} reps",
                                                ),

                                                _buildChip(
                                                  Icons.timer,
                                                  "${exercise["rest"]}s",
                                                ),

                                                _buildChip(
                                                  Icons.sports_gymnastics,
                                                  exercise["muscle"],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: routines.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Color(0xFF00FF88),
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}