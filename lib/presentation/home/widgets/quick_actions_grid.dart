import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    required this.onStartWorkout,
    required this.onLogWeight,
    required this.onViewProgress,
  });

  final VoidCallback onStartWorkout;
  final VoidCallback onLogWeight;
  final VoidCallback onViewProgress;

  @override
  Widget build(BuildContext context) {
    final List<_QuickAction> actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.play_circle_fill,
        label: 'Iniciar entrenamiento',
        description: 'Elige una rutina y comienza a registrar tus sets.',
        onTap: onStartWorkout,
        gradient: const [Color(0xFF3867F4), Color(0xFF6E8BFF)],
      ),
      _QuickAction(
        icon: Icons.monitor_weight_outlined,
        label: 'Log peso',
        description: 'Registra un nuevo peso corporal en segundos.',
        onTap: onLogWeight,
        gradient: const [Color(0xFF00C6A7), Color(0xFF1AD69B)],
      ),
      _QuickAction(
        icon: Icons.stacked_line_chart,
        label: 'Ver progreso',
        description: 'Analiza tus métricas y entrenamientos recientes.',
        onTap: onViewProgress,
        gradient: const [Color(0xFFFF8A60), Color(0xFFFFAF6D)],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 560;
        if (isWide) {
          return Row(
            children: [
              for (int i = 0; i < actions.length; i += 1) ...[
                Expanded(child: _QuickActionCard(action: actions[i])),
                if (i != actions.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (int i = 0; i < actions.length; i += 1) ...[
              _QuickActionCard(action: actions[i]),
              if (i != actions.length - 1) const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    required this.gradient,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final List<Color> gradient;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: action.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(action.icon, color: AppColors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              action.label,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
