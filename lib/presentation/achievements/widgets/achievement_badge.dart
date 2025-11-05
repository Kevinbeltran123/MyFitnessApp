import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class AchievementBadge extends StatefulWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showProgress = false,
    this.showTooltip = true,
    this.highlight = false,
    this.size = 72,
  });

  final Achievement achievement;
  final bool showProgress;
  final bool showTooltip;
  final bool highlight;
  final double size;

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.highlight) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AchievementBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlight && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.highlight && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AchievementBadgeState state = _state;
    final Color accent = _resolveAccent(state);
    final double progress = widget.achievement.progress();

    Widget badge = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
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
                size: widget.size * 0.42,
              ),
            ),
            if (state == AchievementBadgeState.inProgress && widget.showProgress)
              SizedBox(
                width: widget.size,
                height: widget.size,
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
                  width: widget.size * 0.28,
                  height: widget.size * 0.28,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 14, color: AppColors.success),
                ),
              ),
            if (widget.highlight)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double shimmerPosition = _controller.value * 2 - 1;
                    return ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.white.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment(-1 + shimmerPosition, -1),
                            end: Alignment(shimmerPosition, 1),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: widget.size + 16,
          child: Text(
            widget.achievement.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

    if (!widget.showTooltip) {
      return badge;
    }

    final String tooltipMessage = widget.achievement.isUnlocked()
        ? '${widget.achievement.name}\nDesbloqueado'
        : '${widget.achievement.name}\n${widget.achievement.description}\nProgreso ${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%';

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 400),
      child: badge,
    );
  }

  AchievementBadgeState get _state {
    if (widget.achievement.isUnlocked()) {
      return AchievementBadgeState.unlocked;
    }
    if (widget.achievement.progress() > 0) {
      return AchievementBadgeState.inProgress;
    }
    return AchievementBadgeState.locked;
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
    final Color base = _colorFromHex(widget.achievement.badgeColor) ?? AppColors.warning;
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

enum AchievementBadgeState { locked, inProgress, unlocked }

extension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
