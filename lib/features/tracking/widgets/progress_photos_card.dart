import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/body_measurement.dart';
import '../models/progress_photo.dart';

/// Fotos de progreso: "Antes" (la primera) junto a "Ahora" (la más reciente)
/// y la tira con todas. Es lo que más motiva en las apps de progreso: la
/// báscula a veces no se mueve aunque el cuerpo sí cambie.
class ProgressPhotosCard extends StatelessWidget {
  final List<ProgressPhoto> photos;
  final List<BodyMeasurement> measurements;
  final bool uploading;
  final VoidCallback onAdd;
  final void Function(ProgressPhoto) onOpen;

  const ProgressPhotosCard({
    super.key,
    required this.photos,
    required this.measurements,
    required this.uploading,
    required this.onAdd,
    required this.onOpen,
  });

  static const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

  static String dateLabel(ProgressPhoto p) {
    final d = p.dateTime;
    return d == null ? p.date : '${d.day} ${_months[d.month - 1]}';
  }

  /// Peso medido el mismo día o hasta 7 días de diferencia, si lo hay.
  double? _weightNear(ProgressPhoto p) {
    final d = p.dateTime;
    if (d == null) return null;
    BodyMeasurement? best;
    var bestDiff = 8;
    for (final m in measurements) {
      final md = DateTime.tryParse(m.date);
      if (md == null || m.weightKg <= 0) continue;
      final diff = md.difference(d).inDays.abs();
      if (diff < bestDiff) {
        best = m;
        bestDiff = diff;
      }
    }
    return best?.weightKg;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('FOTOS DE PROGRESO',
                  style: AppTextStyles.label.copyWith(color: AppColors.accent, letterSpacing: 1))),
              TextButton.icon(
                onPressed: uploading ? null : onAdd,
                icon: uploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_a_photo_outlined, size: 18),
                label: Text(uploading ? 'Subiendo...' : 'Agregar'),
              ),
            ],
          ),
          if (photos.isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Tómate una foto hoy', style: AppTextStyles.titleMd),
            const SizedBox(height: 4),
            Text(
              'De frente, con la misma luz y ropa ajustada. Repítela cada 2 a 4 semanas '
              'y aquí verás el antes y el ahora lado a lado. Solo tú puedes verlas.',
              style: AppTextStyles.bodySm,
            ),
          ] else if (photos.length == 1) ...[
            const SizedBox(height: AppSpacing.sm),
            _PhotoTile(photo: photos.first, label: 'Inicio', weight: _weightNear(photos.first), onTap: onOpen),
            const SizedBox(height: AppSpacing.sm),
            Text('Toma otra foto en unas semanas para comparar el antes y el ahora.',
                style: AppTextStyles.bodySm),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _PhotoTile(photo: photos.first, label: 'Antes', weight: _weightNear(photos.first), onTap: onOpen),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PhotoTile(photo: photos.last, label: 'Ahora', weight: _weightNear(photos.last), onTap: onOpen),
                ),
              ],
            ),
            if (photos.length > 2) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => onOpen(photos[i]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(photos[i].bytes, width: 48, height: 64, fit: BoxFit.cover, cacheWidth: 144),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final ProgressPhoto photo;
  final String label;
  final double? weight;
  final void Function(ProgressPhoto) onTap;

  const _PhotoTile({required this.photo, required this.label, required this.weight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(photo),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(photo.bytes, fit: BoxFit.cover, cacheWidth: 600),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xCC000000)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label.toUpperCase(),
                          style: AppTextStyles.label.copyWith(color: AppColors.accent, letterSpacing: 1)),
                      Text(
                        [ProgressPhotosCard.dateLabel(photo), if (weight != null) '${weight!.toStringAsFixed(1)} kg']
                            .join(' · '),
                        style: AppTextStyles.bodySm.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
