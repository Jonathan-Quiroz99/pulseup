import 'package:flutter/material.dart';

import '../../core/navigation/app_screen.dart';
import '../../core/theme/app_colors.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/app_nav_bar.dart';

import '../auth/user_session.dart';

import '../billing/billing_screen.dart';
import '../checkin/checkin_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../membership/locked_feature_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../onboarding/section_guide.dart';
import '../onboarding/welcome_tour.dart';
import '../routines/routines_screen.dart';
import '../store/store_screen.dart';
import '../tracking/tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppScreen _currentScreen = AppScreen.dashboard;
  final _navBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SectionGuide.navBarKey = _navBarKey;
    // Primera vez de este socio en la app: bienvenida + mini tutorial.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => WelcomeTour.showIfFirstTime(context),
    );
  }

  @override
  void dispose() {
    if (identical(SectionGuide.navBarKey, _navBarKey)) SectionGuide.navBarKey = null;
    super.dispose();
  }

  void _changeTab(AppScreen screen) {
    if (_currentScreen == screen) return;

    setState(() {
      _currentScreen = screen;
    });
  }

  int _getBottomNavIndex() {
    switch (_currentScreen) {
      case AppScreen.routines:
        return 0;
      case AppScreen.tracking:
        return 1;
      case AppScreen.dashboard:
        return 2;
      case AppScreen.store:
        return 3;
      case AppScreen.checkin:
        return 4;
      case AppScreen.nutrition:
      case AppScreen.billing:
        // No están en la barra inferior (se abren desde el drawer): no
        // resaltar "Inicio" como si lo estuvieran.
        return -1;
    }
  }

  Widget _buildScreen() {
    if (_currentScreen.requiresActivePlan && !UserSession.isActiveMember) {
      return LockedFeatureScreen(
        key: ValueKey(_currentScreen),
        screen: _currentScreen,
        onGoToBilling: () => _changeTab(AppScreen.billing),
        onUnlocked: () => setState(() {}),
      );
    }

    switch (_currentScreen) {
      case AppScreen.dashboard:
        return DashboardScreen(onNavigate: _changeTab);

      case AppScreen.routines:
        return RoutinesScreen(onOpenProgress: () => _changeTab(AppScreen.tracking));

      case AppScreen.tracking:
        return const TrackingScreen();

      case AppScreen.nutrition:
        return const NutritionScreen();

      case AppScreen.store:
        return const StoreScreen();

      case AppScreen.checkin:
        return const CheckinScreen();

      case AppScreen.billing:
        return const BillingScreen();
    }
  }

  /// First name, title-cased — the backend stores some names all-caps.
  String _greetingName() {
    final raw = (UserSession.firstName ??
            UserSession.currentUser?['nombre'] as String? ??
            'Usuario')
        .trim();
    final first = raw.isEmpty ? 'Usuario' : raw.split(' ').first;
    return first[0].toUpperCase() + first.substring(1).toLowerCase();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (_currentScreen) {
      case AppScreen.dashboard:
        return AppBar(
          toolbarHeight: 72,

          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 30,
                height: 30,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PULSEUP',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hola, ${_greetingName()}',
                      style: textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          actions: [
            _guideButton(),

            _drawerButton(),
          ],
        );

      case AppScreen.routines:
        return AppBar(
          title: const Text('Rutinas'),
          actions: [_guideButton(), _drawerButton()],
        );

      case AppScreen.tracking:
        return AppBar(
          title: const Text('Progreso'),
          actions: [_guideButton(), _drawerButton()],
        );

      case AppScreen.nutrition:
        return AppBar(
          title: const Text('Nutrición'),
          actions: [_guideButton(), _drawerButton()],
        );

      case AppScreen.store:
        return AppBar(
          title: const Text('Tienda'),
          actions: [_guideButton(), _drawerButton()],
        );

      case AppScreen.checkin:
        return AppBar(
          title: const Text('Check-In'),
          actions: [_guideButton(), _drawerButton()],
        );

      case AppScreen.billing:
        return AppBar(
          title: const Text('Estado de cuenta'),
          actions: [_guideButton(), _drawerButton()],
        );
    }
  }

  /// "?" para repetir el mini tutorial de la sección visible (solo aparece
  /// si esa pantalla tiene uno).
  Widget _guideButton() {
    return ValueListenableBuilder<VoidCallback?>(
      valueListenable: SectionGuide.replay,
      builder: (_, replay, _) => replay == null
          ? const SizedBox.shrink()
          : IconButton(
              tooltip: 'Cómo usar esta sección',
              onPressed: replay,
              icon: const Icon(Icons.help_outline),
            ),
    );
  }

  Widget _drawerButton() {
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          icon: const Icon(Icons.menu),
        );
      },
    );
  }

  static const _navItems = [
    AppNavItem(icon: Icons.fitness_center, label: 'Rutinas'),
    AppNavItem(icon: Icons.show_chart, label: 'Progreso'),
    AppNavItem(icon: Icons.home, label: 'Inicio'),
    AppNavItem(icon: Icons.storefront, label: 'Tienda'),
    AppNavItem(icon: Icons.qr_code, label: 'Check-In'),
  ];

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        _changeTab(AppScreen.routines);
        break;
      case 1:
        _changeTab(AppScreen.tracking);
        break;
      case 2:
        _changeTab(AppScreen.dashboard);
        break;
      case 3:
        _changeTab(AppScreen.store);
        break;
      case 4:
        _changeTab(AppScreen.checkin);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentScreen == AppScreen.dashboard,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _changeTab(AppScreen.dashboard);
      },
      child: Scaffold(
        extendBody: true,

        appBar: _buildAppBar(context),

        endDrawer: AppDrawer(
          onNavigate: _changeTab,
        ),

        endDrawerEnableOpenDragGesture: true,
        drawerEdgeDragWidth: 32,

        body: ColoredBox(
          color: AppColors.bg,
          child: _buildScreen(),
        ),

        bottomNavigationBar: KeyedSubtree(
          key: _navBarKey,
          child: AppNavBar(
            items: _navItems,
            currentIndex: _getBottomNavIndex(),
            onTap: _onBottomNavTap,
          ),
        ),
      ),
    );
  }
}