import 'package:flutter/material.dart';

class CheckinEmptyState
    extends StatelessWidget {
  const CheckinEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.qr_code_2,
            size: 80,
            color: Colors.white24,
          ),

          const SizedBox(height: 20),

          const Text(
            "Aún no hay registros",

            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}