import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_card.dart';
import '../../routines/models/workout_session.dart';
import '../../routines/services/routine_schedule.dart';

/// Progreso → "Tus entrenamientos": los días de rutina que el socio marcó como
/// terminados, cuántos lleva esta semana y las rutinas completas.
class WorkoutHistoryCard extends StatelessWidget {
  final List<WorkoutSession> sessions;

  /// Cuántos se muestran antes de "Ver todos".
  static const preview = 4;

  const WorkoutHistoryCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final stats = WorkoutStats.from(sessions);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TUS ENTRENAMIENTOS',
              style: AppTextStyles.label.copyWith(color: AppColors.accent, letterSpacing: 1)),
          const SizedBox(height: AppSpacing.md),
          if (sessions.isEmpty)
            Text(
              'Cuando termines un día de tu rutina (en Rutinas, botón "Terminé..."), '
              'aparece aquí.',
              style: AppTextStyles.bodySm,
            )
          else ...[
            Row(
              children: [
                Expanded(child: _Stat(value: '${stats.thisWeek}', label: 'esta semana')),
                Expanded(child: _Stat(value: '${stats.total}', label: stats.total == 1 ? 'día hecho' : 'días hechos')),
                Expanded(
                  child: _Stat(
                    value: '${stats.roundsCompleted}',
                    label: stats.roundsCompleted == 1 ? 'rutina completa' : 'rutinas completas',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            for (final s in sessions.take(preview)) WorkoutSessionTile(session: s),
            if (sessions.length > preview)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showAll(context),
                  child: Text('Ver todos (${sessions.length})'),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showAll(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenX, 0, AppSpacing.screenX, AppSpacing.lg),
          children: [
            Text('Tus entrenamientos', style: AppTextStyles.displayMd),
            const SizedBox(height: AppSpacing.sm),
            for (final s in sessions) WorkoutSessionTile(session: s),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.displayMd),
        Text(label, style: AppTextStyles.label, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Una fila del historial: "Día 2 — Pierna · Full Body 3 días · 18 nov".
class WorkoutSessionTile extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSessionTile({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final (day, focus) = RoutineSchedule.splitDayName(s.day);
    final title = s.day.isEmpty ? s.planName : [day, if (focus.isNotEmpty) focus].join(' — ');
    // La fecha primero: el nombre de la rutina es largo y se corta.
    final subtitle = [
      s.dateLabel,
      if (s.day.isNotEmpty) s.planName,
      '${s.exercises} ejercicios',
    ].join('  ·  ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: s.closesRound ? AppColors.accent : AppColors.accentSoft,
            child: Icon(
              s.closesRound ? Icons.emoji_events : Icons.check,
              size: 18,
              color: s.closesRound ? AppColors.onAccent : AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: AppTextStyles.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (s.closesRound && s.dayCount > 1)
                  Text(
                    'Rutina completa · vuelta ${s.round}',
                    style: AppTextStyles.label.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
