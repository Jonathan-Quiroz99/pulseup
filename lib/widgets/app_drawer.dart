import 'package:flutter/material.dart';
import '../features/auth/user_session.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onNavigate;

  const AppDrawer({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF111111),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          // 🔥 Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),

            accountName: Text(
              UserSession.currentUser?['nombre'] ?? 'Usuario',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            accountEmail: Text(
              "Membresía Activa",
              style: TextStyle(
                color: Colors.greenAccent,
              ),
            ),

            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.greenAccent,
              child: Icon(
                Icons.person,
                color: Colors.black,
              ),
            ),
          ),

          // 🏠 Inicio
          _drawerItem(
            icon: Icons.home,
            title: "Inicio",
            onTap: () {
              Navigator.pop(context);
              onNavigate(0);
            },
          ),

          // 💪 Rutinas
          _drawerItem(
            icon: Icons.fitness_center,
            title: "Rutinas",
            onTap: () {
              Navigator.pop(context);
              onNavigate(1);
            },
          ),

          // 📈 Progreso
          _drawerItem(
            icon: Icons.show_chart,
            title: "Progreso",
            onTap: () {
              Navigator.pop(context);
              onNavigate(2);
            },
          ),

          // 📲 Check-in
          _drawerItem(
            icon: Icons.qr_code,
            title: "Check-in",
            onTap: () {
              Navigator.pop(context);
              onNavigate(3);
            },
          ),

          Divider(color: Colors.white24),

          // 💳 Estado de cuenta
          _drawerItem(
            icon: Icons.credit_card,
            title: "Estado de cuenta",
            onTap: () {
              Navigator.pop(context);
              onNavigate(4);
              // futura pantalla
            },
          ),

          // 💰 Métodos de pago
          _drawerItem(
            icon: Icons.payment,
            title: "Métodos de pago",
            onTap: () {
              Navigator.pop(context);
              

              // futura pantalla
            },
          ),

          Divider(color: Colors.white24),

          // ⚙️ Configuración
          _drawerItem(
            icon: Icons.settings,
            title: "Configuración",
            onTap: () {},
          ),

          // 🚪 Logout
          _drawerItem(
            icon: Icons.logout,
            title: "Cerrar sesión",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.greenAccent,
      ),

      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
        ),
      ),

      onTap: onTap,
    );
  }
}