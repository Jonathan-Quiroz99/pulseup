import 'package:flutter/material.dart';

import '../models/body_measurement.dart';

class MeasurementTile extends StatelessWidget {
  final BodyMeasurement measurement;

  const MeasurementTile({
    super.key,
    required this.measurement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Text(
                measurement.date,

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color:
                      const Color(0x2200FF88),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Text(
                  "${measurement.weightKg} kg",

                  style: const TextStyle(
                    color: Color(0xFF00FF88),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,

            children: [
              _chip(
                "Grasa",
                "${measurement.bodyFat}%",
              ),

              _chip(
                "Músculo",
                "${measurement.muscle}%",
              ),

              _chip(
                "Cintura",
                "${measurement.waist}cm",
              ),

              _chip(
                "Pecho",
                "${measurement.chest}cm",
              ),

              _chip(
                "Brazo",
                "${measurement.arm}cm",
              ),
            ],
          ),

          if (measurement.notes.isNotEmpty) ...[
            const SizedBox(height: 14),

            Text(
              measurement.notes,

              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Text(
        "$label: $value",

        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}