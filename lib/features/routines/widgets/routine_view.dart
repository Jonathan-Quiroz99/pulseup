import 'package:flutter/material.dart';

import '../../../core/http_helpers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_card.dart';
import '../../auth/user_session.dart';
import '../models/workout_exercise.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';
import '../services/routine_schedule.dart';
import '../services/routines_service.dart';
import 'exercise_tile.dart';

/// La rutina actual del socio, organizada por días: arriba "Hoy toca", luego
/// un selector de días y la lista de ejercicios del día elegido. "Terminé"
/// guarda el día en el servidor (cuenta en Progreso) y, al terminar el último
/// día, muestra que la rutina se completó.
class RoutineView extends StatefulWidget {
  final WorkoutPlan routine;

  /// Abre la pestaña de Progreso (desde "Rutina completada").
  final VoidCallback? onOpenProgress;

  /// Para pruebas: por defecto el servicio real.
  final RoutinesService? service;

  /// Para el mini tutorial de Rutinas (opcionales).
  final GlobalKey? todayKey;
  final GlobalKey? daysKey;
  final GlobalKey? exerciseKey;
  final GlobalKey? finishKey;

  const RoutineView({
    super.key,
    required this.routine,
    this.onOpenProgress,
    this.service,
    this.todayKey,
    this.daysKey,
    this.exerciseKey,
    this.finishKey,
  });

  static List<MapEntry<String, List<WorkoutExercise>>> groupByDay(List<WorkoutExercise> exercises) {
    final groups = <String, List<WorkoutExercise>>{};
    for (final e in exercises) {
      groups.putIfAbsent(e.day, () => []).add(e);
    }
    return groups.entries.toList();
  }

  @override
  State<RoutineView> createState() => _RoutineViewState();
}

class _RoutineViewState extends State<RoutineView> {
  late int _completed;
  int? _selected;
  bool _saving = false;

  late List<MapEntry<String, List<WorkoutExercise>>> _days;

  RoutinesService get _service => widget.service ?? RoutinesService();

  @override
  void initState() {
    super.initState();
    _days = RoutineView.groupByDay(widget.routine.exercises);
    _completed = widget.routine.completedSessions;
  }

  @override
  void didUpdateWidget(RoutineView old) {
    super.didUpdateWidget(old);
    if (old.routine != widget.routine) {
      _days = RoutineView.groupByDay(widget.routine.exercises);
      _completed = widget.routine.completedSessions;
      _selected = null;
    }
  }

  int get _today => RoutineSchedule.todayIndex(_completed, _days.length);
  int get _round => RoutineSchedule.currentRound(_completed, _days.length);

  String _shortName(int i) {
    final name = _days[i].key;
    if (name.isEmpty) return _days.length == 1 ? 'Rutina' : 'Día ${i + 1}';
    return RoutineSchedule.splitDayName(name).$1;
  }

  String _focus(int i) => RoutineSchedule.splitDayName(_days[i].key).$2;

  void _snack(String text, {SnackBarAction? action}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text), action: action));
  }

  Future<void> _finishDay(int dayIndex) async {
    final token = UserSession.token;
    if (token == null || _saving) return;
    setState(() => _saving = true);
    final WorkoutSession session;
    try {
      session = await _service.finishDay(token, widget.routine.id, _days[dayIndex].key);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack(friendlyError(e));
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      // El servidor dice en qué día va (un doble toque no cuenta dos).
      _completed = session.completedAfter;
      _selected = null; // salta al nuevo "hoy"
    });
    if (session.closesRound && _days.length > 1) {
      await _showRoundComplete(session);
    } else if (session.closesRound) {
      _snack('¡Rutina completada! Quedó guardada en tu progreso.',
          action: SnackBarAction(label: 'Deshacer', onPressed: () => _undo(session)));
    } else {
      _snack('¡Buen trabajo! Quedó en tu progreso. La próxima vez te toca el ${_shortName(_today)}.',
          action: SnackBarAction(label: 'Deshacer', onPressed: () => _undo(session)));
    }
  }

  Future<void> _undo(WorkoutSession session) async {
    final token = UserSession.token;
    if (token == null) return;
    try {
      await _service.undoDay(token, session.id);
      if (!mounted) return;
      setState(() {
        _completed = session.completedAfter - 1;
        _selected = null;
      });
      _snack('Listo, se quitó el ${_dayLabel(session)} de tu progreso.');
    } catch (e) {
      if (mounted) _snack(friendlyError(e));
    }
  }

  String _dayLabel(WorkoutSession s) {
    if (s.day.isEmpty) return 'entrenamiento';
    return RoutineSchedule.splitDayName(s.day).$1;
  }

  Future<void> _showRoundComplete(WorkoutSession session) async {
    final totalExercises = widget.routine.exercises.length;
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _RoundCompleteSheet(
        routineName: widget.routine.name,
        round: session.round,
        days: [
          for (var i = 0; i < _days.length; i++)
            [_shortName(i), if (_focus(i).isNotEmpty) _focus(i)].join(' — '),
        ],
        totalExercises: totalExercises,
        canOpenProgress: widget.onOpenProgress != null,
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'progress':
        widget.onOpenProgress?.call();
      case 'undo':
        await _undo(session);
      default:
        _snack('Vuelta ${session.round} guardada. La próxima vez empiezas otra vez en el ${_shortName(0)}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_days.isEmpty) {
      return AppCard(child: Text('Tu entrenador aún no agrega ejercicios a esta rutina.',
          style: AppTextStyles.bodySm));
    }
    final selected = (_selected ?? _today).clamp(0, _days.length - 1);
    final exercises = _days[selected].value;
    final focus = _focus(selected);
    final isToday = selected == _today;
    final routine = widget.routine;
    final multiDay = _days.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Encabezado ----
        Text('RUTINA ACTUAL',
            style: AppTextStyles.label.copyWith(color: AppColors.accent, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(routine.name, style: AppTextStyles.displayMd),
        const SizedBox(height: AppSpacing.xs),
        Text(
          [
            if (multiDay) '${_days.length} días',
            '${routine.exercises.length} ejercicios',
            if (routine.trainer.isNotEmpty) 'Coach ${routine.trainer}',
          ].join('  ·  '),
          style: AppTextStyles.label,
        ),
        if (routine.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(routine.description, style: AppTextStyles.bodySm),
        ],
        const SizedBox(height: AppSpacing.lg),

        // ---- Hoy toca ----
        if (multiDay)
          Container(
            key: widget.todayKey,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.today_outlined, color: AppColors.onAccent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HOY TOCA',
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.onAccent, letterSpacing: 1, fontWeight: FontWeight.w700)),
                      Text(
                        [_shortName(_today), if (_focus(_today).isNotEmpty) _focus(_today)].join(' — '),
                        style: AppTextStyles.titleLg.copyWith(color: AppColors.onAccent),
                      ),
                      Text(
                        [
                          '${_days[_today].value.length} ejercicios',
                          if (_completed > 0) 'Vuelta $_round: $_today de ${_days.length} días hechos',
                        ].join('  ·  '),
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.onAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (multiDay) const SizedBox(height: AppSpacing.lg),

        // ---- Selector de días ----
        if (multiDay) ...[
          SingleChildScrollView(
            key: widget.daysKey,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _days.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      // Los días ya hechos en esta vuelta llevan palomita.
                      avatar: i < _today ? const Icon(Icons.check_circle, size: 18) : null,
                      label: Text(i == _today ? '${_shortName(i)} · Hoy' : _shortName(i)),
                      selected: i == selected,
                      onSelected: (_) => setState(() => _selected = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (focus.isNotEmpty) ...[
          Text(focus, style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
        ],

        // ---- Ejercicios del día ----
        for (var i = 0; i < exercises.length; i++) ...[
          KeyedSubtree(
            key: i == 0 ? widget.exerciseKey : null,
            child: ExerciseTile(exercise: exercises[i], number: i + 1),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.sm),
        if (isToday)
          AppButton(
            key: widget.finishKey,
            label: multiDay
                ? (_today == _days.length - 1
                    ? 'Terminé el ${_shortName(selected)} y la rutina'
                    : 'Terminé el ${_shortName(selected)}')
                : 'Terminé mi rutina de hoy',
            icon: Icons.check,
            loading: _saving,
            onPressed: () => _finishDay(selected),
          ),
        if (multiDay && !isToday)
          Text(
            selected < _today
                ? 'Ya hiciste este día en esta vuelta. Hoy te toca el ${_shortName(_today)}.'
                : 'Estás viendo otro día. Hoy te toca el ${_shortName(_today)}.',
            style: AppTextStyles.label,
          ),
      ],
    );
  }
}

/// "¡Completaste tu rutina!": se muestra al terminar el último día de una
/// vuelta. Devuelve 'progress', 'undo' o null (cerrar).
class _RoundCompleteSheet extends StatelessWidget {
  final String routineName;
  final int round;
  final List<String> days;
  final int totalExercises;
  final bool canOpenProgress;

  const _RoundCompleteSheet({
    required this.routineName,
    required this.round,
    required this.days,
    required this.totalExercises,
    required this.canOpenProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenX, 0, AppSpacing.screenX, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(gradient: AppColors.gradient, shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events, size: 40, color: AppColors.onAccent),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('¡Completaste tu rutina!', style: AppTextStyles.displayMd, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
            round > 1
                ? 'Terminaste los ${days.length} días de $routineName por $round.ª vez.'
                : 'Terminaste los ${days.length} días de $routineName.',
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final day in days)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 20, color: AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(day, style: AppTextStyles.titleMd)),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text('$totalExercises ejercicios en total · Vuelta $round',
                    style: AppTextStyles.label),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Quedó guardado en tu Progreso. La próxima vez empiezas una nueva '
            'vuelta en el ${days.first.split(' — ').first}, o pide a tu entrenador '
            'una rutina nueva.',
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (canOpenProgress) ...[
            AppButton(
              label: 'Ver mi progreso',
              icon: Icons.insights_outlined,
              onPressed: () => Navigator.of(context).pop('progress'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppButton(
            label: 'Listo',
            variant: canOpenProgress ? AppButtonVariant.secondary : AppButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('undo'),
            child: const Text('Lo marqué por error'),
          ),
        ],
      ),
    );
  }
}
