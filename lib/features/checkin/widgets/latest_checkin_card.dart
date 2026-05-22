import 'package:flutter/material.dart';

import '../models/checkin_record.dart';

class LatestCheckinCard
    extends StatelessWidget {
  final CheckinRecord checkin;

  const LatestCheckinCard({
    super.key,
    required this.checkin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.history,
            color: Color(0xFF00FF88),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  "Último acceso",

                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${checkin.fecha} • ${checkin.hora}",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}