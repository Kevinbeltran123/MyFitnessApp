import 'package:flutter/material.dart';

import 'package:my_fitness_tracker/models/workout_plan.dart';

class ExerciseGridItem extends StatelessWidget {
  const ExerciseGridItem({
    super.key,
    required this.plan,
    required this.onTap,
    this.onLongPress,
  });

  final WorkoutPlan plan;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = plan.primaryTarget;
    final equipment = plan.equipments.isNotEmpty
        ? plan.equipments.first
        : 'Sin equipo';

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _ExerciseImage(
                gifUrl: plan.gifUrl,
                name: plan.name,
                heroTag: plan.exerciseId,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    plan.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      Chip(
                        label: Text(primary),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text(equipment),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseGridPlaceholder extends StatefulWidget {
  const ExerciseGridPlaceholder({super.key});

  @override
  State<ExerciseGridPlaceholder> createState() =>
      _ExerciseGridPlaceholderState();
}

class _ExerciseGridPlaceholderState extends State<ExerciseGridPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: <Widget>[
          Expanded(child: ShimmerBox(controller: _controller)),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ShimmerLine(widthFactor: 0.8),
                SizedBox(height: 8),
                _ShimmerLine(widthFactor: 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final colorScheme = Theme.of(context).colorScheme;
        final color = Color.lerp(
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface.withValues(alpha: 0.05),
          controller.value,
        );
        return Container(color: color);
      },
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  const _ExerciseImage({
    required this.gifUrl,
    required this.name,
    required this.heroTag,
  });

  final String gifUrl;
  final String name;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );

    if (gifUrl.isEmpty) {
      return placeholder;
    }

    return Hero(
      tag: 'exercise-image-$heroTag',
      child: Image.network(
        gifUrl,
        fit: BoxFit.cover,
        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) {
                return child;
              }
              return placeholder;
            },
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
