import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/application/gamification/streak_tracker.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key, required this.state, this.onStartRoutine});

  final HomeDashboardState state;
  final VoidCallback? onStartRoutine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.greeting,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.motivationalMessage,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _StreakCard(snapshot: state.streakSnapshot),
        if (state.nextRoutine != null) ...[
          const SizedBox(height: 16),
          _NextRoutineCard(
            summary: state.nextRoutine!,
            onStartRoutine: onStartRoutine,
          ),
        ],
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.snapshot});

  final StreakSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.accentBlue, Color(0xFF6DA9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Racha actual',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${snapshot.currentStreak} días',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Mejor racha',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${snapshot.longestStreak} días',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextRoutineCard extends StatelessWidget {
  const _NextRoutineCard({required this.summary, this.onStartRoutine});

  final RoutineSummary summary;
  final VoidCallback? onStartRoutine;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String dateLabel = localizations.formatFullDate(
      summary.nextOccurrence,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.veryLightGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available,
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu próximo entrenamiento',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_focusLabel(summary.focus)} • $dateLabel',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onStartRoutine != null)
            FilledButton(
              onPressed: onStartRoutine,
              child: const Text('Iniciar'),
            ),
        ],
      ),
    );
  }

  static String _focusLabel(RoutineFocus focus) {
    switch (focus) {
      case RoutineFocus.fullBody:
        return 'Cuerpo completo';
      case RoutineFocus.upperBody:
        return 'Tren superior';
      case RoutineFocus.lowerBody:
        return 'Tren inferior';
      case RoutineFocus.push:
        return 'Push';
      case RoutineFocus.pull:
        return 'Pull';
      case RoutineFocus.core:
        return 'Core';
      case RoutineFocus.mobility:
        return 'Movilidad';
      case RoutineFocus.custom:
        return 'Personalizada';
    }
  }
}
