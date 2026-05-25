import 'package:flutter/material.dart';

import '../core/navigation/app_screen.dart';
import '../core/theme/app_spacing.dart';

import '../features/auth/user_session.dart';

class AppDrawer
    extends StatelessWidget {

  final Function(AppScreen)
      onNavigate;

  const AppDrawer({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return Drawer(

      child: ListView(

        padding: EdgeInsets.zero,

        children: [

          UserAccountsDrawerHeader(

            decoration: BoxDecoration(
              color:
                  theme.colorScheme.surface,
            ),

            accountName: Text(

              UserSession.currentUser?[
                      'nombre'] ??
                  'Usuario',

              style: textTheme.titleMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            accountEmail: Text(

              'Membresía Activa',

              style: textTheme.bodyMedium
                  ?.copyWith(
                color: theme
                    .colorScheme.primary,
              ),
            ),

            currentAccountPicture:
                CircleAvatar(

              backgroundColor:
                  theme.colorScheme.primary,

              child: Icon(
                Icons.person,
                color: theme
                    .colorScheme.onPrimary,
              ),
            ),
          ),

          _drawerItem(

            context: context,

            icon: Icons.home,

            title: 'Inicio',

            onTap: () {

              Navigator.pop(context);

              onNavigate(
                AppScreen.dashboard,
              );
            },
          ),

          _drawerItem(

            context: context,

            icon: Icons.fitness_center,

            title: 'Rutinas',

            onTap: () {

              Navigator.pop(context);

              onNavigate(
                AppScreen.routines,
              );
            },
          ),

          _drawerItem(

            context: context,

            icon: Icons.show_chart,

            title: 'Progreso',

            onTap: () {

              Navigator.pop(context);

              onNavigate(
                AppScreen.tracking,
              );
            },
          ),

          _drawerItem(

            context: context,

            icon: Icons.storefront,

            title: 'Tienda',

            onTap: () {

              Navigator.pop(context);

              onNavigate(
                AppScreen.store,
              );
            },
          ),

          _drawerItem(

            context: context,

            icon: Icons.qr_code,

            title: 'Check-In',

            onTap: () {

              Navigator.pop(context);

              onNavigate(
                AppScreen.checkin,
              );
            },
          ),

          const Divider(),

          _drawerItem(

            context: context,

            icon: Icons.credit_card,

            title: 'Estado de cuenta',

            onTap: () {

              Navigator.pop(context);

              onNavigate(
                AppScreen.billing,
              );
            },
          ),

          _drawerItem(

            context: context,

            icon: Icons.payment,

            title: 'Métodos de pago',

            onTap: () {

              Navigator.pop(context);
            },
          ),

          const Divider(),

          _drawerItem(

            context: context,

            icon: Icons.settings,

            title: 'Configuración',

            onTap: () {

              Navigator.pop(context);
            },
          ),

          _drawerItem(

            context: context,

            icon: Icons.logout,

            title: 'Cerrar sesión',

            onTap: () {

              Navigator.pop(context);

              // TODO:
              // Implementar logout
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({

    required BuildContext context,

    required IconData icon,

    required String title,

    required VoidCallback onTap,
  }) {

    final theme =
        Theme.of(context);

    return ListTile(

      leading: Icon(
        icon,
        color:
            theme.colorScheme.primary,
      ),

      title: Text(title),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),

      onTap: onTap,
    );
  }
}