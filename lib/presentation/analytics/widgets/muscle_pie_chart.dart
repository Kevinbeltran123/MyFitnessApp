import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Pie chart displaying muscle group distribution in lifted volume.
class MusclePieChart extends StatefulWidget {
  const MusclePieChart({
    super.key,
    required this.stats,
    required this.totalVolume,
  });

  final List<MuscleGroupStat> stats;
  final double totalVolume;

  @override
  State<MusclePieChart> createState() => _MusclePieChartState();
}

class _MusclePieChartState extends State<MusclePieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = widget.stats;

    if (stats.isEmpty || widget.totalVolume <= 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textTertiary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pie_chart_outline, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Aún no hay suficientes datos de entrenamientos para calcular la distribución muscular.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final int touched = _touchedIndex ?? -1;
    final MuscleGroupStat? focused = (touched >= 0 && touched < stats.length)
        ? stats[touched]
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.15),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      if (!mounted) return;
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null) {
                          _touchedIndex = null;
                        } else {
                          _touchedIndex =
                              response.touchedSection?.touchedSectionIndex;
                        }
                      });
                    },
                  ),
                  sections: List.generate(stats.length, (int index) {
                    final MuscleGroupStat stat = stats[index];
                    final bool isTouched = index == touched;
                    final double radius = isTouched ? 70 : 62;
                    final double percent = stat.percentage.clamp(0, 100);
                    return PieChartSectionData(
                      color: _colorForIndex(index),
                      value: percent <= 0 ? 0.001 : percent,
                      radius: radius,
                      title: '${percent.toStringAsFixed(0)}%',
                      titleStyle: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribución de volumen',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  focused != null
                      ? '${focused.group} • ${focused.percentage.toStringAsFixed(1)}%'
                      : 'Toca un segmento para ver el detalle',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: focused != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: stats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final stat = stats[index];
                      final bool isFocused = index == touched;
                      return _LegendTile(
                        label: stat.group,
                        percentage: stat.percentage,
                        volume: stat.volume,
                        color: _colorForIndex(index),
                        isActive: isFocused,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForIndex(int index) {
    const palette = <Color>[
      AppColors.accentBlue,
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      AppColors.darkBlue,
      AppColors.mediumGray,
      AppColors.mediumDarkGray,
    ];
    if (index < palette.length) {
      return palette[index];
    }
    return palette[index % palette.length];
  }
}

class _LegendTile extends StatelessWidget {
  const _LegendTile({
    required this.label,
    required this.percentage,
    required this.volume,
    required this.color,
    required this.isActive,
  });

  final String label;
  final double percentage;
  final double volume;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.08) : AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.4)
              : AppColors.textTertiary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% • ${_formatVolume(volume)} kg',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatVolume(double value) {
    if (value >= 1000) {
      final double thousands = value / 1000;
      final String formatted = thousands >= 10
          ? thousands.toStringAsFixed(0)
          : thousands.toStringAsFixed(1);
      return '${formatted}k';
    }
    return value.toStringAsFixed(0);
  }
}
