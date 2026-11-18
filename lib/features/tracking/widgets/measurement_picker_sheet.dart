import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_button.dart';
import '../models/body_measurement.dart';
import 'progress_photos_card.dart';

/// "¿De qué registro es esta foto?": lista los registros de peso (el más
/// reciente arriba) y devuelve el elegido. Se usa al analizar una foto que
/// no tiene registro (fotos viejas) o para cambiarlo.
class MeasurementPickerSheet extends StatefulWidget {
  final List<BodyMeasurement> measurements;
  final String? initialId;

  const MeasurementPickerSheet({
    super.key,
    required this.measurements,
    this.initialId,
  });

  static Future<BodyMeasurement?> show(
    BuildContext context, {
    required List<BodyMeasurement> measurements,
    String? initialId,
  }) {
    return showModalBottomSheet<BodyMeasurement>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      builder: (_) => MeasurementPickerSheet(
        measurements: measurements,
        initialId: initialId,
      ),
    );
  }

  /// "84.0 kg · 17 nov"
  static String label(BodyMeasurement m) =>
      '${m.weightKg.toStringAsFixed(1)} kg · ${ProgressPhotosCard.dayLabel(m.date)}';

  @override
  State<MeasurementPickerSheet> createState() => _MeasurementPickerSheetState();
}

class _MeasurementPickerSheetState extends State<MeasurementPickerSheet> {
  late final List<BodyMeasurement> valid =
      widget.measurements.where((m) => m.weightKg > 0).toList();

  // El registro sugerido, si sigue existiendo; si no, el más reciente.
  late String? _selected = valid.any((m) => m.id == widget.initialId)
      ? widget.initialId
      : (valid.isEmpty ? null : valid.first.id);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenX, AppSpacing.lg, AppSpacing.screenX, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿De qué registro es esta foto?', style: AppTextStyles.titleLg),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Usamos el peso y la cintura de ese registro para calcular tu '
                'composición, y ahí se guarda el resultado.',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: RadioGroup<String>(
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final m in valid)
                        RadioListTile<String>(
                          value: m.id,
                          contentPadding: EdgeInsets.zero,
                          title: Text(MeasurementPickerSheet.label(m), style: AppTextStyles.titleMd),
                          subtitle: m.waist != null
                              ? Text('Cintura ${m.waist!.toStringAsFixed(1)} cm',
                                  style: AppTextStyles.bodySm)
                              : null,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Usar este registro',
                icon: Icons.check_rounded,
                onPressed: _selected == null
                    ? null
                    : () => Navigator.pop(
                          context,
                          valid.firstWhere((m) => m.id == _selected),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
