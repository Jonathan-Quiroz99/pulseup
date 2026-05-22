import 'package:flutter/material.dart';

class LastCheckinTile
    extends StatelessWidget {
  final String date;
  final String time;

  const LastCheckinTile({
    super.key,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.access_time,
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
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "$date • $time",

                  style: const TextStyle(
                    color: Colors.white,
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