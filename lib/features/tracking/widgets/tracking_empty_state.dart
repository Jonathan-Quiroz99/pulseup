import 'package:flutter/material.dart';

class TrackingEmptyState
    extends StatelessWidget {

  const TrackingEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final textTheme =
        Theme.of(context).textTheme;

    return Center(

      child: Text(
        'No hay registros todavía',
        style:
            textTheme.bodyLarge,
      ),
    );
  }
}