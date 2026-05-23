import 'package:flutter/material.dart';

import '../../../core/navigation/app_screen.dart';
import '../../../core/theme/app_spacing.dart';

class QuickActionsGrid
    extends StatelessWidget {

  final Function(AppScreen)
      onNavigate;

  const QuickActionsGrid({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {

    return GridView.count(

      crossAxisCount: 4,

      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      crossAxisSpacing:
          AppSpacing.sm,

      mainAxisSpacing:
          AppSpacing.sm,

      childAspectRatio: 0.9,

      children: [

        _ActionItem(
          icon: Icons.qr_code,
          label: 'Check-In',
          onTap: () {

            onNavigate(
              AppScreen.checkin,
            );
          },
        ),

        _ActionItem(
          icon: Icons.fitness_center,
          label: 'Rutinas',
          onTap: () {

            onNavigate(
              AppScreen.routines,
            );
          },
        ),

        _ActionItem(
          icon: Icons.show_chart,
          label: 'Progreso',
          onTap: () {

            onNavigate(
              AppScreen.tracking,
            );
          },
        ),

        _ActionItem(
          icon: Icons.credit_card,
          label: 'Cuenta',
          onTap: () {

            onNavigate(
              AppScreen.billing,
            );
          },
        ),
      ],
    );
  }
}

class _ActionItem
    extends StatelessWidget {

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    return InkWell(

      borderRadius:
          BorderRadius.circular(
        AppSpacing.radiusMd,
      ),

      onTap: onTap,

      child: Ink(

        decoration: BoxDecoration(

          color:
              theme.cardColor,

          borderRadius:
              BorderRadius.circular(
            AppSpacing.radiusMd,
          ),
        ),

        child: Padding(

          padding: const EdgeInsets.all(
            AppSpacing.sm,
          ),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Icon(
                icon,
                color:
                    theme.colorScheme.primary,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                label,
                textAlign: TextAlign.center,
                style:
                    textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}