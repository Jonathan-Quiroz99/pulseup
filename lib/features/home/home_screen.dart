import 'package:flutter/material.dart';

import '../../core/navigation/app_screen.dart';

import '../../widgets/app_drawer.dart';

import '../auth/user_session.dart';

import '../billing/billing_screen.dart';
import '../checkin/checkin_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../routines/routines_screen.dart';
import '../store/store_screen.dart';
import '../tracking/tracking_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  AppScreen _currentScreen =
      AppScreen.dashboard;

  void _changeTab(
    AppScreen screen,
  ) {

    if (_currentScreen == screen) {
      return;
    }

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

      case AppScreen.billing:
        return 2;
    }
  }

  Widget _buildScreen() {

    switch (_currentScreen) {

      case AppScreen.dashboard:

        return DashboardScreen(
          onNavigate: _changeTab,
        );

      case AppScreen.routines:

        return const RoutinesScreen();

      case AppScreen.tracking:

        return const TrackingScreen();

      case AppScreen.store:

        return const StoreScreen();

      case AppScreen.checkin:

        return const CheckinScreen();

      case AppScreen.billing:

        return const BillingScreen();
    }
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

          actions: [
            _drawerButton(),
          ],
        );

      case AppScreen.tracking:

        return AppBar(

          title: const Text(
            'Progreso',
          ),

          actions: [
            _drawerButton(),
          ],
        );

      case AppScreen.store:

        return AppBar(

          title: const Text(
            'Tienda',
          ),

          actions: [
            _drawerButton(),
          ],
        );

      case AppScreen.checkin:

        return AppBar(

          title: const Text(
            'Check-In',
          ),

          actions: [
            _drawerButton(),
          ],
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

    switch (index) {

      case 0:

        _changeTab(
          AppScreen.routines,
        );

        break;

      case 1:

        _changeTab(
          AppScreen.tracking,
        );

        break;

      case 2:

        _changeTab(
          AppScreen.dashboard,
        );

        break;

      case 3:

        _changeTab(
          AppScreen.store,
        );

        break;

      case 4:

        _changeTab(
          AppScreen.checkin,
        );

        break;
    }
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
            _buildScreen(),

        bottomNavigationBar:
            BottomNavigationBar(

          currentIndex:
              _getBottomNavIndex(),

          onTap:
              _onBottomNavTap,

          type:
              BottomNavigationBarType.fixed,

          items: const [

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
                Icons.home,
              ),

              label: 'Inicio',
            ),

            BottomNavigationBarItem(

              icon: Icon(
                Icons.storefront,
              ),

              label: 'Tienda',
            ),

            BottomNavigationBarItem(

              icon: Icon(
                Icons.qr_code,
              ),

              label: 'Check-In',
            ),
          ],
        ),
      ),
    );
  }
}