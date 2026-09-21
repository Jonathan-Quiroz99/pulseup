import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// The QR stays on a white card on purpose — scanners need the contrast.
/// Text inside it uses [AppColors.onLight].
class QRCard extends StatelessWidget {
  final String qrData;
  final String? memberName;
  final String? memberId;

  const QRCard({
    super.key,
    required this.qrData,
    this.memberName,
    this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ambientShadow,
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (memberName != null && memberName!.isNotEmpty)
            Text(
              memberName!,
              style: AppTextStyles.titleMd.copyWith(color: AppColors.onLight),
            ),
          if (memberId != null && memberId!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              memberId!,
              style: AppTextStyles.label.copyWith(color: const Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }
}
