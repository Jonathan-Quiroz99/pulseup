import 'package:flutter/material.dart';

import 'package:pulseup/features/billing/billing_screen.dart';

import '../routines/routines_screen.dart';
import '../tracking/tracking_screen.dart';
import '../checkin/checkin_screen.dart';
import '../auth/user_session.dart';

import '../../widgets/app_drawer.dart';

import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  // 🔥 Cambiar pantalla
  void changeTab(int index) {

    setState(() {
      currentIndex = index;
    });
  }

  // 🎯 AppBar dinámica
  PreferredSizeWidget currentAppBar() {

    switch (currentIndex) {

      // 🏠 Dashboard
      case 0:
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
      case 1:
        return AppBar(
          title: Text("Rutinas"),
        );

      // 📈 Tracking
      case 2:
        return AppBar(
          title: Text("Progreso"),
        );

      // 📲 Check-In
      case 3:
        return AppBar(
          title: Text("Check-In"),
        );

      // 💳 Billing
      case 4:
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

      default:
        return AppBar(
          title: Text("PulseUp"),
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    final screens = [

      // 🏠 Dashboard
      DashboardScreen(
        onNavigate: changeTab,
      ),

      // 💪 Rutinas
      RoutinesScreen(),

      // 📈 Tracking
      TrackingScreen(),

      // 📲 Check-In
      CheckinScreen(),

      // 💳 Billing
      BillingScreen(),
    ];

    return PopScope(

      canPop: currentIndex == 0,

      onPopInvoked: (didPop) {

        if (didPop) return;

        // 🔙 Si no estás en Inicio
        // regresar al Dashboard

        setState(() {
          currentIndex = 0;
        });
      },
    
      child: Scaffold(

      // 🔥 Swipe drawer
      endDrawerEnableOpenDragGesture: true,

      drawerEdgeDragWidth: 60,

      // 🔥 AppBar global
      appBar: currentAppBar(),

      // 📂 Drawer global
      endDrawer: AppDrawer(
        onNavigate: changeTab,
      ),

      // 📱 Pantalla actual
      body: screens[currentIndex],

      // 🔻 Bottom Navigation
      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: changeTab,

        type:
            BottomNavigationBarType.fixed,

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