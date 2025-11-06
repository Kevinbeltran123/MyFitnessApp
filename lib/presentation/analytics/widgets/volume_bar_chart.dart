import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Bar chart displaying lifted volume per week/month for the selected period.
class VolumeBarChart extends StatelessWidget {
  const VolumeBarChart({super.key, required this.series});

  final VolumeSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = series.points;

    if (series.maxVolume <= 0) {
      return Container(
        height: 240,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textTertiary.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bar_chart_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'Aún no hay datos de volumen en este periodo',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final double chartMaxY = _calculateChartMax(series.maxVolume);
    final double interval = chartMaxY / 4;

    final bars = List<BarChartGroupData>.generate(points.length, (int index) {
      final point = points[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: point.volume,
            width: 16,
            gradient: const LinearGradient(
              colors: [AppColors.accentBlue, AppColors.lightBlue],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(8),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: chartMaxY,
              color: AppColors.lightGray,
            ),
          ),
        ],
      );
    });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.darkGray, AppColors.mediumDarkGray],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_formatVolume(points.last.volume)} kg',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.textTertiary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) =>
                          _buildLeftTitle(value, meta, theme),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => _buildBottomTitle(
                        value,
                        meta,
                        theme,
                        series.aggregation,
                        points.length,
                      ),
                    ),
                  ),
                ),
                barGroups: bars,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipMargin: 8,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tooltipRoundedRadius: 10,
                    getTooltipColor: (group) =>
                        AppColors.darkGray.withValues(alpha: 0.85),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final int index = group.x.toInt();
                      if (index < 0 || index >= points.length) {
                        return null;
                      }
                      final point = points[index];
                      final String periodLabel = _bottomLabel(
                        series.aggregation,
                        index,
                      );
                      return BarTooltipItem(
                        '$periodLabel\n',
                        const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${_formatVolume(point.volume)} kg',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: '\n${_formatRange(point)}',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const String _title = 'Volumen levantado';

  static double _calculateChartMax(double maxValue) {
    if (maxValue <= 0) {
      return 10;
    }
    final double padded = maxValue * 1.1;
    return padded < 10 ? 10 : padded;
  }

  static Widget _buildLeftTitle(double value, TitleMeta meta, ThemeData theme) {
    if (value < 0) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        _formatAxisLabel(value),
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _buildBottomTitle(
    double value,
    TitleMeta meta,
    ThemeData theme,
    VolumeAggregation aggregation,
    int itemCount,
  ) {
    final int index = value.toInt();
    final bool isWholeNumber = value.roundToDouble() == value;
    if (!isWholeNumber || index < 0 || index >= itemCount) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _bottomLabel(aggregation, index),
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  static String _bottomLabel(VolumeAggregation aggregation, int index) {
    switch (aggregation) {
      case VolumeAggregation.weekly:
        return 'Sem ${index + 1}';
      case VolumeAggregation.monthly:
        return 'Mes ${index + 1}';
    }
  }

  static String _formatRange(VolumeDataPoint point) {
    final start = _formatDate(point.start);
    final end = _formatDate(point.end);
    return '$start – $end';
  }

  static String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  static String _formatVolume(double value) {
    if (value >= 1000) {
      final double inThousands = value / 1000;
      final String formatted = (inThousands >= 10)
          ? inThousands.toStringAsFixed(0)
          : inThousands.toStringAsFixed(1);
      return '${formatted}k';
    }
    return value.toStringAsFixed(0);
  }

  static String _formatAxisLabel(double value) {
    if (value <= 0) {
      return '0';
    }
    if (value >= 1000) {
      final double thousands = value / 1000;
      return thousands >= 10
          ? '${thousands.toStringAsFixed(0)}k'
          : '${thousands.toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}
