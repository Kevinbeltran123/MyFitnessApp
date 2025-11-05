import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/gamification/streak_tracker.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/presentation/achievements/achievements_providers.dart';
import 'package:my_fitness_tracker/presentation/achievements/widgets/achievement_badge.dart';
import 'package:my_fitness_tracker/presentation/achievements/widgets/achievement_unlock_modal.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';
import 'package:my_fitness_tracker/presentation/achievements/widgets/streak_counter.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final milestone = ref.watch(streakMilestoneProvider);
    final highlightId = ref.watch(latestUnlockedAchievementProvider);

    ref.listen<AsyncValue<List<Achievement>>>(achievementsProvider,
        (previous, next) {
      if (!next.hasValue) {
        return;
      }
      final achievements = next.value ?? const <Achievement>[];
      final unlockedIds = achievements
          .where((achievement) => achievement.isUnlocked())
          .map((achievement) => achievement.id)
          .toSet();
      final seenNotifier = ref.read(seenAchievementsProvider.notifier);

      if (previous == null && seenNotifier.state.isEmpty) {
        seenNotifier.state = unlockedIds;
        return;
      }

      final String? newId = unlockedIds
          .firstWhereOrNull((id) => !seenNotifier.state.contains(id));

      if (newId != null) {
        seenNotifier.state = {...seenNotifier.state, newId};
        ref.read(latestUnlockedAchievementProvider.notifier).state = newId;
        final Achievement achievement =
            achievements.firstWhere((item) => item.id == newId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAchievementUnlockModal(context, achievement).whenComplete(() {
            ref.read(latestUnlockedAchievementProvider.notifier).state = null;
          });
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros'),
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorStateWidget(
          title: 'No pudimos cargar tus logros',
          message: error.toString(),
          onRetry: () => ref.invalidate(achievementsProvider),
        ),
        data: (achievements) => _AchievementsContent(
          achievements: achievements,
          streak: streakAsync.valueOrNull,
          milestone: milestone,
          highlightedAchievementId: highlightId,
          onDismissMilestone: () =>
              ref.read(streakMilestoneProvider.notifier).state = null,
          onRefresh: () async {
            ref.invalidate(achievementsProvider);
            ref.invalidate(currentStreakProvider);
          },
        ),
      ),
    );
  }
}

class _AchievementsContent extends StatelessWidget {
  const _AchievementsContent({
    required this.achievements,
    required this.streak,
    required this.milestone,
    required this.highlightedAchievementId,
    required this.onDismissMilestone,
    required this.onRefresh,
  });

  final List<Achievement> achievements;
  final StreakSnapshot? streak;
  final int? milestone;
  final String? highlightedAchievementId;
  final VoidCallback onDismissMilestone;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.emoji_events_outlined,
        title: 'Aún no hay logros',
        message: 'Sigue utilizando la app para comenzar a desbloquear badges.',
      );
    }

    final unlocked = achievements.where((achievement) => achievement.isUnlocked()).length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (milestone != null)
                    _MilestoneBanner(
                      milestone: milestone!,
                      onDismiss: onDismissMilestone,
                    ),
                  const SizedBox(height: 12),
                  if (streak != null)
                    StreakCounter(snapshot: streak!)
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.veryLightGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_outlined,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Comienza a registrar tus sesiones para construir una racha.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Has desbloqueado $unlocked de ${achievements.length} logros',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final achievement = achievements[index];
                  final bool unlocked = achievement.isUnlocked();
                  final double progress = achievement.progress();

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.textTertiary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AchievementBadge(
                            achievement: achievement,
                            showProgress: !unlocked,
                            highlight: highlightedAchievementId == achievement.id,
                            size: 72,
                          ),
                          Column(
                            children: [
                              Text(
                                achievement.description,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: unlocked ? 1 : progress,
                                minHeight: 6,
                                backgroundColor: AppColors.veryLightGray,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  unlocked ? AppColors.success : AppColors.accentBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                unlocked
                                    ? 'Logro desbloqueado'
                                    : 'Progreso ${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: achievements.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneBanner extends StatelessWidget {
  const _MilestoneBanner({required this.milestone, required this.onDismiss});

  final int milestone;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.celebration, color: AppColors.success, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Nuevo hito desbloqueado!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Has alcanzado una racha de $milestone días. Celebra y sigue sumando.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
