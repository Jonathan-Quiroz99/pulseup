import 'package:flutter/material.dart';

import '../../core/navigation/app_screen.dart';

import '../../widgets/app_drawer.dart';

import '../auth/user_session.dart';

import '../billing/billing_screen.dart';
import '../checkin/checkin_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../routines/routines_screen.dart';
import '../tracking/tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  AppScreen _currentScreen =
      AppScreen.dashboard;

  late final Map<AppScreen, Widget>
      _screens = {

    AppScreen.dashboard:
        DashboardScreen(
      onNavigate: _changeTab,
    ),

    AppScreen.routines:
        const RoutinesScreen(),

    AppScreen.tracking:
        const TrackingScreen(),

    AppScreen.checkin:
        const CheckinScreen(),

    AppScreen.billing:
        const BillingScreen(),
  };

  void _changeTab(
    AppScreen screen,
  ) {

    setState(() {
      _currentScreen = screen;
    });
  }

  int _getNavIndex() {

    return AppScreen.values.indexOf(
      _currentScreen,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {

    final textTheme =
        Theme.of(context).textTheme;

    switch (_currentScreen) {

      case AppScreen.dashboard:

        return AppBar(

          toolbarHeight: 72,

          title: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Text(
                'PulseUp',
                style:
                    textTheme.bodySmall,
              ),

              Text(
                'Hola, ${UserSession.currentUser?['nombre'] ?? 'Usuario'} 👋',
                style:
                    textTheme.titleLarge,
              ),
            ],
          ),

          actions: [

            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
              ),
            ),

            _drawerButton(),
          ],
        );

      case AppScreen.routines:

        return AppBar(
          title: const Text(
            'Rutinas',
          ),
        );

      case AppScreen.tracking:

        return AppBar(
          title: const Text(
            'Progreso',
          ),
        );

      case AppScreen.checkin:

        return AppBar(
          title: const Text(
            'Check-In',
          ),
        );

      case AppScreen.billing:

        return AppBar(

          title: const Text(
            'Estado de cuenta',
          ),

          actions: [
            _drawerButton(),
          ],
        );
    }
  }

  Widget _drawerButton() {

    return Builder(

      builder: (context) {

        return IconButton(

          onPressed: () {

            Scaffold.of(context)
                .openEndDrawer();
          },

          icon: const Icon(
            Icons.menu,
          ),
        );
      },
    );
  }

  void _onBottomNavTap(
    int index,
  ) {

    _changeTab(
      AppScreen.values[index],
    );
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(

      canPop:
          _currentScreen ==
          AppScreen.dashboard,

      onPopInvoked: (didPop) {

        if (didPop) return;

        _changeTab(
          AppScreen.dashboard,
        );
      },

      child: Scaffold(

        appBar:
            _buildAppBar(context),

        endDrawer: AppDrawer(
          onNavigate: _changeTab,
        ),

        body:
            _screens[_currentScreen],

        bottomNavigationBar:
            BottomNavigationBar(

          currentIndex:
              _getNavIndex(),

          onTap:
              _onBottomNavTap,

          items: const [

            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard,
              ),
              label: 'Inicio',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.fitness_center,
              ),
              label: 'Rutinas',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.show_chart,
              ),
              label: 'Progreso',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.qr_code,
              ),
              label: 'Check-In',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.credit_card,
              ),
              label: 'Cuenta',
            ),
          ],
        ),
      ),
    );
  }
}