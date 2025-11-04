import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

enum AchievementBadgeState { locked, inProgress, unlocked }

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showProgress = false,
    this.showTooltip = true,
    this.size = 72,
  });

  final Achievement achievement;
  final bool showProgress;
  final bool showTooltip;
  final double size;

  AchievementBadgeState get _state {
    if (achievement.isUnlocked()) {
      return AchievementBadgeState.unlocked;
    }
    if (achievement.progress() > 0) {
      return AchievementBadgeState.inProgress;
    }
    return AchievementBadgeState.locked;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AchievementBadgeState state = _state;
    final Color accent = _resolveAccent(state);
    final double progress = achievement.progress();

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: state == AchievementBadgeState.unlocked
                    ? LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: state == AchievementBadgeState.locked
                    ? AppColors.lightGray
                    : accent.withValues(alpha: 0.2),
                border: Border.all(
                  color: state == AchievementBadgeState.locked
                      ? AppColors.textTertiary.withValues(alpha: 0.3)
                      : accent,
                  width: 2,
                ),
              ),
              child: Icon(
                _resolveIcon(state),
                color: state == AchievementBadgeState.locked
                    ? AppColors.textTertiary
                    : accent.darken(0.1),
                size: size * 0.42,
              ),
            ),
            if (state == AchievementBadgeState.inProgress && showProgress)
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
            if (state == AchievementBadgeState.unlocked)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 14, color: AppColors.success),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size + 16,
          child: Text(
            achievement.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (!showTooltip) {
      return content;
    }

    final String tooltipMessage = achievement.isUnlocked()
        ? '${achievement.name}\nDesbloqueado'
        : '${achievement.name}\n${achievement.description}\nProgreso ${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%';

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 400),
      child: content,
    );
  }

  IconData _resolveIcon(AchievementBadgeState state) {
    switch (state) {
      case AchievementBadgeState.locked:
        return Icons.lock_outline;
      case AchievementBadgeState.inProgress:
        return Icons.hourglass_bottom;
      case AchievementBadgeState.unlocked:
        return Icons.emoji_events_outlined;
    }
  }

  Color _resolveAccent(AchievementBadgeState state) {
    final Color base = _colorFromHex(achievement.badgeColor) ?? AppColors.warning;
    switch (state) {
      case AchievementBadgeState.locked:
        return base.withValues(alpha: 0.5);
      case AchievementBadgeState.inProgress:
        return base.withValues(alpha: 0.8);
      case AchievementBadgeState.unlocked:
        return base;
    }
  }

  Color? _colorFromHex(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final String hex = value.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return null;
  }
}

extension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
