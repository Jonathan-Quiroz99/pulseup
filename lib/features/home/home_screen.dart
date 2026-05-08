import 'package:flutter/material.dart';

import 'package:pulseup/features/billing/billing_screen.dart';

import '../../core/navigation/app_screen.dart';

import '../routines/routines_screen.dart';
import '../tracking/tracking_screen.dart';
import '../checkin/checkin_screen.dart';
import '../auth/user_session.dart';

import '../../widgets/app_drawer.dart';

import 'dashboard/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  AppScreen currentScreen =
      AppScreen.dashboard;

  // 🔥 Cambiar pantalla
  void changeTab(AppScreen screen) {

    setState(() {
      currentScreen = screen;
    });
  }

  // 🔢 Enum -> BottomNav index
  int getNavIndex() {

    switch (currentScreen) {

      case AppScreen.dashboard:
        return 0;

      case AppScreen.routines:
        return 1;

      case AppScreen.tracking:
        return 2;

      case AppScreen.checkin:
        return 3;

      case AppScreen.billing:
        return 4;
    }
  }

  // 📱 Pantalla actual
  Widget currentPage() {

    switch (currentScreen) {

      case AppScreen.dashboard:
        return DashboardScreen(
          onNavigate: changeTab,
        );

      case AppScreen.routines:
        return RoutinesScreen();

      case AppScreen.tracking:
        return TrackingScreen();

      case AppScreen.checkin:
        return CheckinScreen();

      case AppScreen.billing:
        return BillingScreen();
    }
  }

  // 🎯 AppBar dinámica
  PreferredSizeWidget currentAppBar() {

    switch (currentScreen) {

      // 🏠 Dashboard
      case AppScreen.dashboard:

        return AppBar(

          toolbarHeight: 70,

          title: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Text(
                "PulseUp",

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              Text(
                "Hola, ${UserSession.currentUser?['nombre'] ?? 'Usuario'} 👋",

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          actions: [

            IconButton(
              icon: Icon(Icons.notifications_none),
              onPressed: () {},
            ),

            Builder(
              builder: (context) => IconButton(

                icon: Icon(Icons.menu),

                onPressed: () {
                  Scaffold.of(context)
                      .openEndDrawer();
                },
              ),
            ),
          ],
        );

      // 💪 Rutinas
      case AppScreen.routines:

        return AppBar(
          title: Text("Rutinas"),
        );

      // 📈 Tracking
      case AppScreen.tracking:

        return AppBar(
          title: Text("Progreso"),
        );

      // 📲 Check-In
      case AppScreen.checkin:

        return AppBar(
          title: Text("Check-In"),
        );

      // 💳 Billing
      case AppScreen.billing:

        return AppBar(

          title: Text("Estado de cuenta"),

          actions: [

            Builder(
              builder: (context) => IconButton(

                icon: Icon(Icons.menu),

                onPressed: () {
                  Scaffold.of(context)
                      .openEndDrawer();
                },
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(

      // 🔙 Solo cerrar app
      // si estamos en dashboard
      canPop:
          currentScreen ==
          AppScreen.dashboard,

      onPopInvoked: (didPop) {

        if (didPop) return;

        // 🔙 Regresar a dashboard

        setState(() {
          currentScreen =
              AppScreen.dashboard;
        });
      },

      child: Scaffold(

        // 👉 Swipe desde borde derecho
        endDrawerEnableOpenDragGesture:
            true,

        drawerEdgeDragWidth: 60,

        // 🔥 AppBar global
        appBar: currentAppBar(),

        // 📂 Drawer global
        endDrawer: AppDrawer(
          onNavigate: changeTab,
        ),

        // 📱 Screen actual
        body: currentPage(),

        // 🔻 Bottom nav
        bottomNavigationBar:
            BottomNavigationBar(

          currentIndex: getNavIndex(),

          type:
              BottomNavigationBarType.fixed,

          onTap: (index) {

            switch (index) {

              case 0:
                changeTab(
                  AppScreen.dashboard,
                );
                break;

              case 1:
                changeTab(
                  AppScreen.routines,
                );
                break;

              case 2:
                changeTab(
                  AppScreen.tracking,
                );
                break;

              case 3:
                changeTab(
                  AppScreen.checkin,
                );
                break;

              case 4:
                changeTab(
                  AppScreen.billing,
                );
                break;
            }
          },

          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Inicio",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: "Rutinas",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: "Progreso",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: "Check-In",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: "Cuenta",
            ),
          ],
        ),
      ),
    );
  }
}