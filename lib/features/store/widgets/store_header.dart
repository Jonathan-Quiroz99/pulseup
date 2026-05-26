import 'package:flutter/material.dart';

class StoreHeader extends StatelessWidget {
  final String title;

  const StoreHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.store, color: Colors.black),
          ),

          const SizedBox(width: 12),

          Text(
            title,
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}