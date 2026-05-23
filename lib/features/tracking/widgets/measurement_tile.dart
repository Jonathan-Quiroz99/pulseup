import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../models/body_measurement.dart';

class MeasurementTile
    extends StatelessWidget {

  final BodyMeasurement
      measurement;

  const MeasurementTile({
    super.key,
    required this.measurement,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return Card(

      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),

      child: Padding(

        padding: const EdgeInsets.all(
          AppSpacing.md,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Text(
                  measurement.date,
                  style:
                      textTheme.titleMedium,
                ),

                Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        AppSpacing.sm,
                    vertical:
                        AppSpacing.xs,
                  ),

                  decoration:
                      BoxDecoration(

                    color: theme
                        .colorScheme.primary
                        .withOpacity(0.12),

                    borderRadius:
                        BorderRadius.circular(
                      AppSpacing.radiusMd,
                    ),
                  ),

                  child: Text(
                    '${measurement.weightKg} kg',

                    style: textTheme.bodyMedium
                        ?.copyWith(
                      color: theme
                          .colorScheme.primary,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            Wrap(

              spacing: AppSpacing.sm,

              runSpacing:
                  AppSpacing.sm,

              children: [

                _MeasurementChip(
                  label: 'Grasa',
                  value:
                      '${measurement.bodyFat}%',
                ),

                _MeasurementChip(
                  label: 'Músculo',
                  value:
                      '${measurement.muscle}%',
                ),

                _MeasurementChip(
                  label: 'Cintura',
                  value:
                      '${measurement.waist}cm',
                ),

                _MeasurementChip(
                  label: 'Pecho',
                  value:
                      '${measurement.chest}cm',
                ),

                _MeasurementChip(
                  label: 'Brazo',
                  value:
                      '${measurement.arm}cm',
                ),
              ],
            ),

            if (measurement
                .notes.isNotEmpty) ...[

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Text(
                measurement.notes,
                style:
                    textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasurementChip
    extends StatelessWidget {

  final String label;
  final String value;

  const _MeasurementChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),

      decoration: BoxDecoration(

        color:
            theme.colorScheme.surfaceVariant,

        borderRadius:
            BorderRadius.circular(
          AppSpacing.radiusMd,
        ),
      ),

      child: Text(
        '$label: $value',
        style:
            textTheme.bodySmall,
      ),
    );
  }
}