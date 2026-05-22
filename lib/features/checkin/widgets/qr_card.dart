import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCard extends StatelessWidget {
  final String qrData;

  const QRCard({
    super.key,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(28),
      ),

      child: Column(
        children: [
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 260,
          ),

          const SizedBox(height: 20),

          const Text(
            "Escanea este código en recepción",

            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}