import 'package:flutter/material.dart';

import '../models/checkin_record.dart';

class CheckinHistoryTile
    extends StatelessWidget {
  final CheckinRecord checkin;

  const CheckinHistoryTile({
    super.key,
    required this.checkin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color:
                  const Color(0x2200FF88),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: const Icon(
              Icons.login,
              color: Color(0xFF00FF88),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  checkin.tipo,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${checkin.fecha} • ${checkin.hora}",

                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  checkin.puerta,

                  style: const TextStyle(
                    color: Colors.white54,
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