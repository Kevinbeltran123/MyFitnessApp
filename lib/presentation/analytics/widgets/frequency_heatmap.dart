import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// GitHub-style heatmap for training frequency across the last 90 days.
class FrequencyHeatmap extends StatefulWidget {
  const FrequencyHeatmap({
    super.key,
    required this.points,
  });

  final List<DailyActivityPoint> points;

  @override
  State<FrequencyHeatmap> createState() => _FrequencyHeatmapState();
}

class _FrequencyHeatmapState extends State<FrequencyHeatmap> {
  DailyActivityPoint? _focused;

  @override
  void initState() {
    super.initState();
    if (widget.points.isNotEmpty) {
      _focused = widget.points.lastWhere(
        (point) => point.sessionCount > 0,
        orElse: () => widget.points.last,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.2)),
        ),
        child: const Text(
          'Sin datos de entrenamientos en los últimos 90 días.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final double maxVolume = widget.points.fold<double>(
      0,
      (double acc, DailyActivityPoint point) =>
          math.max(acc, point.totalVolume.abs()),
    );
    final List<List<DailyActivityPoint?>> weeks = _groupByWeek(widget.points);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const double cellSize = 18;
            const double spacing = 4;
            final double availableWidth = constraints.maxWidth;
            final double gridWidth =
                (weeks.length * cellSize) + ((weeks.length - 1) * spacing);
            final double viewportWidth = math.max(availableWidth, gridWidth);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: viewportWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DayLabels(cellSize: cellSize, spacing: spacing),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(weeks.length, (int weekIndex) {
                        final List<DailyActivityPoint?> week = weeks[weekIndex];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: weekIndex == weeks.length - 1 ? 0 : spacing,
                          ),
                          child: Column(
                            children: List.generate(7, (int dayIndex) {
                              final DailyActivityPoint? point = week[dayIndex];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: dayIndex == 6 ? 0 : spacing,
                                ),
                                child: _HeatCell(
                                  point: point,
                                  size: cellSize,
                                  isSelected: point != null && point == _focused,
                                  color: _colorForPoint(point, maxVolume),
                                  onTap: () {
                                    if (point == null) return;
                                    setState(() {
                                      _focused = point;
                                    });
                                  },
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (_focused != null) _DetailCard(point: _focused!),
        const SizedBox(height: 12),
        _Legend(maxVolume: maxVolume),
      ],
    );
  }

  List<List<DailyActivityPoint?>> _groupByWeek(List<DailyActivityPoint> points) {
    final List<List<DailyActivityPoint?>> weeks = <List<DailyActivityPoint?>>[];
    List<DailyActivityPoint?> currentWeek = List<DailyActivityPoint?>.filled(7, null);
    int previousWeekday = -1;

    for (final DailyActivityPoint point in points) {
      final int weekdayIndex = point.date.weekday - 1; // Monday = 0
      if (weekdayIndex <= previousWeekday) {
        weeks.add(currentWeek);
        currentWeek = List<DailyActivityPoint?>.filled(7, null);
      }
      currentWeek[weekdayIndex] = point;
      previousWeekday = weekdayIndex;
    }

    weeks.add(currentWeek);
    return weeks;
  }

  Color _colorForPoint(DailyActivityPoint? point, double maxVolume) {
    if (point == null || point.sessionCount == 0) {
      return AppColors.lightGray;
    }
    if (maxVolume <= 0) {
      return AppColors.success.withValues(alpha: 0.4);
    }
    final double ratio = (point.totalVolume / maxVolume).clamp(0, 1);
    final Color base = AppColors.success.withValues(alpha: 0.25);
    return Color.lerp(base, AppColors.success, ratio) ?? AppColors.success;
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({
    required this.point,
    required this.size,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final DailyActivityPoint? point;
  final double size;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(4);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
          border: Border.all(
            color: isSelected
                ? AppColors.darkBlue.withValues(alpha: 0.7)
                : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: point != null && isSelected
            ? Text(
                '${point!.sessionCount}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            : null,
      ),
    );
  }
}

class _DayLabels extends StatelessWidget {
  const _DayLabels({required this.cellSize, required this.spacing});

  final double cellSize;
  final double spacing;

  static const List<String> _labels = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 6 ? 0 : spacing),
          child: SizedBox(
            width: cellSize,
            height: cellSize,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                _labels[index],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.point});

  final DailyActivityPoint point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights_outlined, color: AppColors.accentBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formattedDate(point.date),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${point.sessionCount} entrenamientos • ${_formatVolume(point.totalVolume)} kg',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formattedDate(DateTime date) {
    final List<String> months = <String>[
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final String day = date.day.toString().padLeft(2, '0');
    final String month = months[date.month - 1];
    return '$day de $month';
  }

  static String _formatVolume(double value) {
    if (value <= 0) {
      return '0';
    }
    if (value >= 1000) {
      final double thousands = value / 1000;
      final String formatted =
          thousands >= 10 ? thousands.toStringAsFixed(0) : thousands.toStringAsFixed(1);
      return '${formatted}k';
    }
    return value.toStringAsFixed(0);
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.maxVolume});

  final double maxVolume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Color> scale = <Color>[
      AppColors.lightGray,
      AppColors.success.withValues(alpha: 0.25),
      Color.lerp(AppColors.success.withValues(alpha: 0.25), AppColors.success, 0.33)!,
      Color.lerp(AppColors.success.withValues(alpha: 0.25), AppColors.success, 0.66)!,
      AppColors.success,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Menos',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        for (final color in scale)
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.15)),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          'Más',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
