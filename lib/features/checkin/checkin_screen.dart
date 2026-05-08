import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';

class CheckinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CustomCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code, size: 120, color: Colors.greenAccent),
              SizedBox(height: 20),
              Text("QR dinámico (simulado)"),
            ],
          ),
        ),
      ),
    );
  }
}