import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/presentation/achievements/widgets/achievement_badge.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showAchievementUnlockModal(
  BuildContext context,
  Achievement achievement,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(context) + const EdgeInsets.all(16),
        child: _AchievementUnlockContent(achievement: achievement),
      );
    },
  );
}

class _AchievementUnlockContent extends StatefulWidget {
  const _AchievementUnlockContent({required this.achievement});

  final Achievement achievement;

  @override
  State<_AchievementUnlockContent> createState() => _AchievementUnlockContentState();
}

class _AchievementUnlockContentState extends State<_AchievementUnlockContent>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2))
      ..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            AppColors.success,
            AppColors.warning,
            AppColors.accentBlue,
          ],
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.15)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, color: AppColors.warning, size: 32),
              const SizedBox(height: 16),
              Text(
                '¡Logro desbloqueado!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AchievementBadge(
                achievement: widget.achievement,
                showProgress: false,
                showTooltip: false,
                highlight: true,
                size: 88,
              ),
              const SizedBox(height: 12),
              Text(
                widget.achievement.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.achievement.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Share.share(
                          'Acabo de desbloquear el logro "${widget.achievement.name}" en My Fitness Tracker 💪',
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Compartir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
