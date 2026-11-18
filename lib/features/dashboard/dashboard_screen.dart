import 'package:flutter/material.dart';

import '../../core/navigation/app_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/section_header.dart';

import '../auth/user_session.dart';
import '../onboarding/section_guide.dart';

import 'models/dashboard_stats.dart';
import 'models/dashboard_workout.dart';

import 'services/dashboard_service.dart';

import 'widgets/challenge_card.dart';
import 'widgets/dashboard_header_card.dart';
import 'widgets/dashboard_loading.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/stats_row.dart';
import 'widgets/workout_card.dart';

class DashboardScreen extends StatefulWidget {
  final Function(AppScreen) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final ApiService _apiService = ApiService();

  // Starts true: the first load runs from initState, where calling
  // setState() synchronously would throw.
  bool _loading = true;

  DashboardWorkout? _workout;
  DashboardStats? _stats;
  int _weeklyCheckins = 0;

  // Mini tutorial de Inicio.
  final _headerKey = GlobalKey();
  final _mainCardKey = GlobalKey();
  final _quickKey = GlobalKey();
  bool _guideChecked = false;

  @override
  void initState() {
    super.initState();
    SectionGuide.attach(this, () => SectionGuide.show(context, _guideSteps()));
    _loadDashboard();
  }

  @override
  void dispose() {
    SectionGuide.detach(this);
    super.dispose();
  }

  List<GuideStep> _guideSteps() => [
        GuideStep(
          target: _headerKey,
          icon: Icons.card_membership_outlined,
          title: 'Tu membresía',
          body: 'Aquí ves tu plan y si está activo.',
        ),
        if (UserSession.isActiveMember)
          GuideStep(
            target: _mainCardKey,
            icon: Icons.fitness_center,
            title: 'Tu entrenamiento de hoy',
            body: _workout != null
                ? 'Tócalo para ver los ejercicios que te tocan hoy.'
                : 'Aquí aparecerá tu rutina del día cuando tu entrenador te '
                    'asigne una.',
          )
        else
          GuideStep(
            target: _mainCardKey,
            icon: Icons.lock_open_rounded,
            title: 'Activa tu membresía',
            body: 'Toca aquí para pagar en línea o ver tu estado de cuenta. '
                'Rutinas, progreso y nutrición se desbloquean al activarla.',
          ),
        GuideStep(
          target: _quickKey,
          icon: Icons.touch_app_outlined,
          title: 'Accesos rápidos',
          body: 'Atajos a tu credencial (Check-In), rutinas, progreso y tu cuenta.',
        ),
        GuideStep(
          target: SectionGuide.navBarKey,
          icon: Icons.menu,
          title: 'Muévete por la app',
          body: 'Usa la barra de abajo para cambiar de sección. Nutrición y tu '
              'estado de cuenta están en el menú (arriba a la derecha). El '
              'botón ? te repite cómo usar cada sección.',
        ),
      ];

  /// Runs [task], returning [fallback] if it throws. Each dashboard card
  /// loads independently — one failing endpoint shouldn't blank the whole
  /// screen. Auth (401) errors are already handled globally by
  /// checkAuthResponse before they reach here.
  Future<T> _guard<T>(Future<T> Function() task, T fallback, String label) async {
    try {
      return await task();
    } catch (e) {
      debugPrint('Dashboard: $label failed: $e');
      return fallback;
    }
  }

  Future<void> _loadDashboard() async {
    final token = UserSession.token;
    if (token == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (!_loading) {
      setState(() => _loading = true);
    }

    final results = await Future.wait([
      _guard<DashboardWorkout?>(
          () => _dashboardService.fetchWorkout(token), null, 'workout'),
      _guard<DashboardStats?>(
          () => _dashboardService.fetchStats(token), null, 'stats'),
      _guard<int>(
          () => _dashboardService.fetchWeeklyCheckins(token), 0, 'checkins'),
      // El estado del plan (Activo/Pendiente) venia solo de la sesion guardada
      // al iniciar sesion: si recepcion activaba la membresia, el Inicio seguia
      // diciendo "Pendiente" aunque se refrescara.
      _guard<void>(() async {
        await UserSession.mergeProfile(await _apiService.getMemberProfile(token));
      }, null, 'profile'),
    ]);

    if (!mounted) return;

    setState(() {
      _workout = results[0] as DashboardWorkout?;
      _stats = results[1] as DashboardStats?;
      _weeklyCheckins = results[2] as int;
      _loading = false;
    });
    if (!_guideChecked) {
      _guideChecked = true;
      SectionGuide.showIfFirstTime(context, 'inicio', _guideSteps);
    }
  }

  /// Sin membresía activa no hay rutina ni progreso que mostrar: en su
  /// lugar, qué falta para activarla.
  Widget _activatePlanCard() {
    final expired = UserSession.membershipStatus == 'Vencido';
    return AppCard(
      elevated: true,
      borderColor: AppColors.accent.withValues(alpha: 0.5),
      onTap: () => widget.onNavigate(AppScreen.billing),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentSoft,
            ),
            child: const Icon(Icons.lock_open_rounded, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expired ? 'Renueva tu membresía' : 'Activa tu membresía',
                    style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(
                  expired
                      ? 'Renueva para volver a tus rutinas, progreso y nutrición.'
                      : 'Rutinas, progreso y nutrición se desbloquean cuando tu '
                          'pago aparezca como pagado.',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(padding: EdgeInsets.zero, child: DashboardLoading());
    }

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.navBarClearance,
          ),
          children: [
            KeyedSubtree(
              key: _headerKey,
              child: DashboardHeader(
                membership: UserSession.membership,
                status: UserSession.membershipStatus,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (UserSession.isActiveMember) ...[
              KeyedSubtree(
                key: _mainCardKey,
                child: WorkoutCard(workout: _workout, onNavigate: widget.onNavigate),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Tu progreso'),
              StatsRow(stats: _stats),
            ] else
              KeyedSubtree(key: _mainCardKey, child: _activatePlanCard()),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Accesos rápidos'),
            KeyedSubtree(
              key: _quickKey,
              child: QuickActionsGrid(onNavigate: widget.onNavigate),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Actividad'),
            ChallengeCard(checkins: _weeklyCheckins),
          ],
        ),
      ),
    );
  }
}
