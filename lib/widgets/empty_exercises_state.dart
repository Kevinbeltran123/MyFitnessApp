import 'package:flutter/material.dart';

class EmptyExercisesState extends StatelessWidget {
  const EmptyExercisesState({super.key, required this.message, this.onReset});

  final String message;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.search_off, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (onReset != null) ...<Widget>[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onReset,
                child: const Text('Restablecer filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
