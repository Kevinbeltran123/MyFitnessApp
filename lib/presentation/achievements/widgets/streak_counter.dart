import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/application/gamification/streak_tracker.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class StreakCounter extends StatelessWidget {
  const StreakCounter({
    super.key,
    required this.snapshot,
    this.daysToDisplay = 7,
  });

  final StreakSnapshot snapshot;
  final int daysToDisplay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<_DayStatus> recentDays = _buildRecentDays(daysToDisplay);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.grayGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${snapshot.currentStreak} días de racha',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Mejor racha: ${snapshot.longestStreak} días',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: recentDays
                .map(
                  (day) => Column(
                    children: [
                      Text(
                        day.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: day.active
                              ? AppColors.success.withValues(alpha: 0.9)
                              : AppColors.white.withValues(alpha: 0.2),
                          border: Border.all(
                            color: day.isToday
                                ? AppColors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          Text(
            _buildMotivationalMessage(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<_DayStatus> _buildRecentDays(int count) {
    final Set<DateTime> active = snapshot.recentActiveDays
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();
    final DateTime today = DateTime.now();
    return List<_DayStatus>.generate(count, (index) {
      final DateTime date = today.subtract(Duration(days: count - index - 1));
      final DateTime normalized = DateTime(date.year, date.month, date.day);
      final bool isActive = active.contains(normalized);
      const List<String> weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
      final String label = weekdayLabels[normalized.weekday - 1];
      return _DayStatus(
        label: label,
        active: isActive,
        isToday:
            normalized.year == today.year &&
            normalized.month == today.month &&
            normalized.day == today.day,
      );
    });
  }

  String _buildMotivationalMessage() {
    if (snapshot.currentStreak == 0) {
      return '¡Comienza hoy y crea tu nueva racha!';
    }
    if (snapshot.milestoneReached != null) {
      return '🎉 Alcanzaste ${snapshot.milestoneReached} días consecutivos. ¡Sigue así!';
    }
    if (snapshot.currentStreak < 3) {
      return 'Gran inicio, mantén el ritmo los próximos días.';
    }
    if (snapshot.currentStreak < 7) {
      return '¡Vas genial! Estás a nada de la racha semanal.';
    }
    return 'Tu constancia es admirable. ¡A por la siguiente meta!';
  }
}

class _DayStatus {
  const _DayStatus({
    required this.label,
    required this.active,
    required this.isToday,
  });

  final String label;
  final bool active;
  final bool isToday;
}
