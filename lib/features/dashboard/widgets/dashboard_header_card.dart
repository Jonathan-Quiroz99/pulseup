import 'package:flutter/material.dart';

class DashboardHeader
    extends StatelessWidget {
  final String name;

  const DashboardHeader({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                "Bienvenido 👋",

                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                name,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: const Color(
              0x2200FF88,
            ),

            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          child: const Icon(
            Icons.fitness_center,
            color: Color(0xFF00FF88),
          ),
        ),
      ],
    );
  }
}