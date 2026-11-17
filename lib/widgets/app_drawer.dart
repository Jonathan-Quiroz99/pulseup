import 'package:flutter/material.dart';

import '../core/navigation/app_screen.dart';
import '../core/server_settings_dialog.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

import '../features/auth/user_session.dart';
import '../features/auth/login_screen.dart';
import '../features/onboarding/welcome_tour.dart';
import 'ui/status_badge.dart';

class AppDrawer extends StatelessWidget {
  final Function(AppScreen) onNavigate;

  const AppDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  _item(context, Icons.home_outlined, 'Inicio',
                      AppScreen.dashboard),
                  _item(context, Icons.fitness_center_outlined, 'Rutinas',
                      AppScreen.routines),
                  _item(context, Icons.show_chart_outlined, 'Progreso',
                      AppScreen.tracking),
                  _item(context, Icons.restaurant_outlined, 'Nutrición',
                      AppScreen.nutrition),
                  _item(context, Icons.storefront_outlined, 'Tienda',
                      AppScreen.store),
                  _item(context, Icons.qr_code_2_outlined, 'Check-In',
                      AppScreen.checkin),
                  const Divider(),
                  _item(context, Icons.receipt_long_outlined,
                      'Estado de cuenta', AppScreen.billing),
                  ListTile(
                    leading: const Icon(Icons.help_outline,
                        color: AppColors.textSecondary),
                    title: Text('Ver tutorial', style: AppTextStyles.body),
                    onTap: () {
                      Navigator.pop(context);
                      WelcomeTour.show(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Center(child: ServerStatusButton()),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text('Cerrar sesión',
                  style: AppTextStyles.body.copyWith(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                await UserSession.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final image = UserSession.profileImage;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.accentSoft,
            backgroundImage: image != null ? NetworkImage(image) : null,
            child: image == null
                ? const Icon(Icons.person_outline, color: AppColors.accent)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserSession.fullName.isEmpty
                      ? 'Usuario'
                      : UserSession.fullName,
                  style: AppTextStyles.titleMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                StatusBadge.fromEstado(UserSession.membershipStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    AppScreen screen,
  ) {
    final locked = screen.requiresActivePlan && !UserSession.isActiveMember;
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.body),
      trailing: locked
          ? const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted)
          : null,
      onTap: () {
        Navigator.pop(context);
        onNavigate(screen);
      },
    );
  }
}
