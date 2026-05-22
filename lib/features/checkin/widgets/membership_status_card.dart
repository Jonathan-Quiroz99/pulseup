import 'package:flutter/material.dart';

class MembershipStatusCard
    extends StatelessWidget {
  final String membership;
  final String status;

  const MembershipStatusCard({
    super.key,
    required this.membership,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),

        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color:
                  const Color(0x2200FF88),

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: const Icon(
              Icons.workspace_premium,
              color: Color(0xFF00FF88),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  membership,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  status,

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
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