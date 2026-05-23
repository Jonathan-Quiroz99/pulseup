import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_spacing.dart';

class QRCard
    extends StatelessWidget {

  final String qrData;

  const QRCard({
    super.key,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {

    final textTheme =
        Theme.of(context).textTheme;

    return Card(

      color: Colors.white,

      shape: RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
          AppSpacing.radiusXl,
        ),
      ),

      child: Padding(

        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),

        child: Column(

          children: [

            QrImageView(
              data: qrData,
              version:
                  QrVersions.auto,
              size: 260,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(

              'Escanea este código en recepción',

              textAlign:
                  TextAlign.center,

              style: textTheme
                  .titleMedium
                  ?.copyWith(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}