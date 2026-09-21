import 'package:flutter/material.dart';

import '../../../widgets/ui/empty_state.dart';

class CheckinEmptyState extends StatelessWidget {
  const CheckinEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.history_toggle_off_outlined,
      title: 'Aún no hay registros',
      message: 'Tus entradas al gimnasio aparecerán aquí.',
    );
  }
}
