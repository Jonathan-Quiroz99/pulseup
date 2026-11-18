import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_card.dart';
import '../models/workout_exercise.dart';
import '../models/workout_plan.dart';
import '../services/routine_schedule.dart';
import 'exercise_tile.dart';

/// La rutina actual del socio, organizada por días: arriba "Hoy toca", luego
/// un selector de días y la lista de ejercicios del día elegido.
class RoutineView extends StatefulWidget {
  final WorkoutPlan routine;

  /// Para el mini tutorial de Rutinas (opcionales).
  final GlobalKey? todayKey;
  final GlobalKey? daysKey;
  final GlobalKey? exerciseKey;
  final GlobalKey? finishKey;

  const RoutineView({
    super.key,
    required this.routine,
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
  int _completed = 0;
  int? _selected;

  late List<MapEntry<String, List<WorkoutExercise>>> _days;

  @override
  void initState() {
    super.initState();
    _days = RoutineView.groupByDay(widget.routine.exercises);
    RoutineSchedule.completedCount(widget.routine.id).then((c) {
      if (mounted) setState(() => _completed = c);
    });
  }

  @override
  void didUpdateWidget(RoutineView old) {
    super.didUpdateWidget(old);
    if (old.routine != widget.routine) {
      _days = RoutineView.groupByDay(widget.routine.exercises);
    }
  }

  int get _today => RoutineSchedule.todayIndex(_completed, _days.length);

  String _shortName(int i) {
    final name = _days[i].key;
    if (name.isEmpty) return _days.length == 1 ? 'Rutina' : 'Día ${i + 1}';
    return RoutineSchedule.splitDayName(name).$1;
  }

  String _focus(int i) => RoutineSchedule.splitDayName(_days[i].key).$2;

  Future<void> _finishDay() async {
    final total = await RoutineSchedule.markDone(widget.routine.id);
    if (!mounted) return;
    setState(() {
      _completed = total;
      _selected = null; // salta al nuevo "hoy"
    });
    final next = _shortName(RoutineSchedule.todayIndex(total, _days.length));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Buen trabajo! La próxima vez te toca el $next.')),
    );
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
            if (_days.length > 1) '${_days.length} días',
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
        if (_days.length > 1)
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
                      Text('${_days[_today].value.length} ejercicios',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.onAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (_days.length > 1) const SizedBox(height: AppSpacing.lg),

        // ---- Selector de días ----
        if (_days.length > 1) ...[
          SingleChildScrollView(
            key: widget.daysKey,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _days.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
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
        if (_days.length > 1 && isToday)
          AppButton(
            key: widget.finishKey,
            label: 'Terminé el ${_shortName(selected)}',
            icon: Icons.check,
            onPressed: _finishDay,
          ),
        if (_days.length > 1 && !isToday)
          Text('Estás viendo otro día. Hoy te toca el ${_shortName(_today)}.',
              style: AppTextStyles.label),
      ],
    );
  }
}
