import 'package:flutter/material.dart';

import 'package:my_fitness_tracker/models/workout_plan.dart';

class WorkoutDetailSheet extends StatelessWidget {
  const WorkoutDetailSheet({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (BuildContext context, ScrollController controller) {
        return SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: mediaQuery.viewPadding.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                plan.name,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (plan.hasGif)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    plan.gifUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              _TagSection(
                label: 'Músculos objetivo',
                values: plan.targetMuscles,
              ),
              const SizedBox(height: 12),
              _TagSection(
                label: 'Partes del cuerpo',
                values: plan.bodyParts,
              ),
              const SizedBox(height: 12),
              _TagSection(
                label: 'Equipamiento',
                values: plan.equipments,
              ),
              const SizedBox(height: 12),
              if (plan.secondaryMuscles.isNotEmpty)
                _TagSection(
                  label: 'Músculos secundarios',
                  values: plan.secondaryMuscles,
                ),
              const SizedBox(height: 20),
              Text(
                'Instrucciones',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...plan.instructions
                  .asMap()
                  .entries
                  .map(
                    (MapEntry<int, String> entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${entry.key + 1}. '),
                          Expanded(child: Text(entry.value)),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({
    required this.label,
    required this.values,
  });

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (String value) => Chip(
                  label: Text(value),
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
