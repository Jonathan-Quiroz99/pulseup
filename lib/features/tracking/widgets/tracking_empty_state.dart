import 'package:flutter/material.dart';

import '../../../widgets/ui/empty_state.dart';

class TrackingEmptyState extends StatelessWidget {
  const TrackingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.show_chart_outlined,
      title: 'Sin registros todavía',
      message: 'Agrega tu primera medición para empezar a ver tu progreso.',
    );
  }
}
