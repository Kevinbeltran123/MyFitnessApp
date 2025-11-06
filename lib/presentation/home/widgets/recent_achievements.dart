import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/presentation/achievements/widgets/achievement_badge.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class RecentAchievementsSection extends StatelessWidget {
  const RecentAchievementsSection({
    super.key,
    required this.achievements,
    this.onViewAll,
  });

  final List<Achievement> achievements;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Logros recientes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (onViewAll != null)
              TextButton(onPressed: onViewAll, child: const Text('Ver todos')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return AchievementBadge(
                achievement: achievement,
                showProgress: false,
                showTooltip: true,
                size: 80,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemCount: achievements.length,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '¡Sigue así! Estos son tus últimos logros desbloqueados.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
