import 'package:flutter/material.dart';

class TrackingEmptyState extends StatelessWidget {
  const TrackingEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No hay registros todavía",

        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );
  }
}