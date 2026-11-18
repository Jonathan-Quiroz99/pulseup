import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../core/theme/app_spacing.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/empty_state.dart';

import '../auth/user_session.dart';
import '../onboarding/section_guide.dart';

import 'models/workout_plan.dart';
import 'services/routines_service.dart';

import 'widgets/routine_card.dart';
import 'widgets/routine_view.dart';

class RoutinesScreen
    extends StatefulWidget {

  /// Lleva a Progreso (desde "¡Completaste tu rutina!").
  final VoidCallback? onOpenProgress;

  const RoutinesScreen({
    super.key,
    this.onOpenProgress,
  });

  @override
  State<RoutinesScreen>
      createState() =>
          _RoutinesScreenState();
}

class _RoutinesScreenState
    extends State<RoutinesScreen> {

  final RoutinesService
      _routinesService =
          RoutinesService();

  bool _loading = false;

  List<WorkoutPlan> _routines = [];

  // Mini tutorial de Rutinas (solo cuando ya hay una rutina que señalar).
  final _todayKey = GlobalKey();
  final _daysKey = GlobalKey();
  final _exerciseKey = GlobalKey();
  final _finishKey = GlobalKey();

  @override
  void initState() {

    super.initState();

    SectionGuide.attach(this, () => SectionGuide.show(context, _guideSteps()));
    _loadRoutines();
  }

  @override
  void dispose() {
    SectionGuide.detach(this);
    super.dispose();
  }

  List<GuideStep> _guideSteps() {
    if (_routines.isEmpty) {
      return const [
        GuideStep(
          icon: Icons.fitness_center,
          title: 'Aquí verás tu rutina',
          body: 'Cuando tu entrenador te asigne una, aparece aquí organizada '
              'por días, con la imagen de cada ejercicio.',
        ),
      ];
    }
    return [
      GuideStep(
        target: _todayKey,
        icon: Icons.today_outlined,
        title: 'Hoy toca',
        body: 'Te decimos qué día de tu rutina te toca hoy.',
      ),
      GuideStep(
        target: _daysKey,
        icon: Icons.calendar_view_week_outlined,
        title: 'Cambia de día',
        body: 'Toca un día para ver sus ejercicios.',
      ),
      GuideStep(
        target: _exerciseKey,
        icon: Icons.touch_app_outlined,
        title: 'Toca un ejercicio',
        body: 'Ve la imagen de cómo se hace, las series y las repeticiones.',
      ),
      GuideStep(
        target: _finishKey,
        icon: Icons.check,
        title: 'Al terminar',
        body: 'Presiona "Terminé..." y queda guardado en tu Progreso. La próxima '
            'vez te toca el siguiente día; al terminar el último completas la rutina.',
      ),
    ];
  }

  Future<void>
      _loadRoutines() async {

    final token =
        UserSession.token;

    if (token == null ||
        token.isEmpty) {

      return;
    }

    setState(() {
      _loading = true;
    });

    try {

      final data =
          await _routinesService
              .fetchMyWorkouts(
        token,
      );

      if (!mounted) return;

      setState(() {
        _routines = data;
      });

    } catch (e) {

      debugPrint(
        'Routines Error: $e',
      );

    } finally {

      if (mounted) {
        setState(() {
          _loading = false;
        });
        // Sin rutinas no se marca como visto: sale cuando llegue la primera.
        if (_routines.any((r) => r.isActive)) {
          SectionGuide.showIfFirstTime(context, 'rutinas', _guideSteps);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_routines.isEmpty) {
      return const AppScaffold(
        padding: EdgeInsets.zero,
        child: EmptyState(
          icon: Icons.fitness_center_outlined,
          title: 'Sin rutinas asignadas',
          message: 'Tu entrenador publicará aquí tu plan de entrenamiento.',
        ),
      );
    }

    // Cuando el gimnasio asigna una rutina nueva, la anterior queda
    // "Inactivo": se muestra la actual y el historial va plegado abajo.
    final current = _routines.where((r) => r.isActive).toList();
    final previous = _routines.where((r) => !r.isActive).toList();

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _loadRoutines,
        child: ListView(
          scrollCacheExtent: const ScrollCacheExtent.pixels(3000),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.navBarClearance,
          ),
          children: [
            for (final routine in current) ...[
              RoutineView(
                key: ValueKey(routine.id),
                routine: routine,
                onOpenProgress: widget.onOpenProgress,
                // Solo la primera rutina actual lleva las marcas del tutorial.
                todayKey: routine == current.first ? _todayKey : null,
                daysKey: routine == current.first ? _daysKey : null,
                exerciseKey: routine == current.first ? _exerciseKey : null,
                finishKey: routine == current.first ? _finishKey : null,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (current.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: EmptyState(
                  icon: Icons.fitness_center_outlined,
                  title: 'Sin rutina actual',
                  message: 'Pide a tu entrenador que te asigne una nueva.',
                ),
              ),
            if (previous.isNotEmpty)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text('Rutinas anteriores (${previous.length})'),
                  children: [
                    for (final routine in previous) ...[
                      RoutineCard(routine: routine),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}