import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Enum for metric types to display in charts
enum MetricType { weight, bodyFat, muscleMass }

/// Simple line chart widget for displaying metric progress over time.
///
/// Uses gray gradients for a professional look.
class MetricChart extends StatelessWidget {
  const MetricChart({
    super.key,
    required this.metrics,
    required this.metricType,
    this.goalValue,
  });

  final List<BodyMetric> metrics;
  final MetricType metricType;
  final double? goalValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataPoints = _extractDataPoints();

    if (dataPoints.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Sin datos para mostrar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final minPoint = dataPoints.reduce(
      (value, element) => element.value < value.value ? element : value,
    );
    final maxPoint = dataPoints.reduce(
      (value, element) => element.value > value.value ? element : value,
    );

    final values = dataPoints.map((e) => e.value).toList();
    final double minValue = values.reduce((a, b) => a < b ? a : b);
    final double maxValue = values.reduce((a, b) => a > b ? a : b);
    final double rawRange = maxValue - minValue;
    final double padding = (rawRange == 0 ? 1 : rawRange) * 0.1;
    final double adjustedMin = minValue - padding;
    final double adjustedMax = maxValue + padding;
    final spots = dataPoints.indexed
        .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2.value))
        .toList(growable: false);

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTitle(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.chartGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatValue(dataPoints.last.value),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              _buildChartData(
                dataPoints: dataPoints,
                spots: spots,
                chartMinY: adjustedMin,
                chartMaxY: adjustedMax,
                actualMinValue: minValue,
                actualMaxValue: maxValue,
                minPoint: minPoint,
                maxPoint: maxPoint,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(dataPoints.first.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                _formatDate(dataPoints.last.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_DataPoint> _extractDataPoints() {
    final points = <_DataPoint>[];

    for (final metric in metrics) {
      double? value;

      switch (metricType) {
        case MetricType.weight:
          value = metric.weightKg;
          break;
        case MetricType.bodyFat:
          value = metric.bodyFatPercentage;
          break;
        case MetricType.muscleMass:
          value = metric.muscleMassKg;
          break;
      }

      if (value != null) {
        points.add(_DataPoint(date: metric.recordedAt, value: value));
      }
    }

    // Sort by date (oldest to newest for chart)
    points.sort((a, b) => a.date.compareTo(b.date));

    // Limit to last 30 data points for readability
    return points.length > 30 ? points.sublist(points.length - 30) : points;
  }

  String _getTitle() {
    switch (metricType) {
      case MetricType.weight:
        return 'Peso';
      case MetricType.bodyFat:
        return 'Grasa Corporal';
      case MetricType.muscleMass:
        return 'Masa Muscular';
    }
  }

  String _formatValue(double value) {
    switch (metricType) {
      case MetricType.weight:
      case MetricType.muscleMass:
        return '${value.toStringAsFixed(1)} kg';
      case MetricType.bodyFat:
        return '${value.toStringAsFixed(1)}%';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  LineChartData _buildChartData({
    required List<_DataPoint> dataPoints,
    required List<FlSpot> spots,
    required double chartMinY,
    required double chartMaxY,
    required double actualMinValue,
    required double actualMaxValue,
    required _DataPoint minPoint,
    required _DataPoint maxPoint,
  }) {
    final double minX = 0;
    final double maxX = spots.isEmpty ? 1 : spots.last.x;
    final gradientColors = <Color>[AppColors.accentBlue, AppColors.lightBlue];
    final areaColors = <Color>[
      AppColors.accentBlue.withValues(alpha: 0.25),
      AppColors.accentBlue.withValues(alpha: 0.05),
    ];

    final double range = (chartMaxY - chartMinY).abs();
    final double interval = range < 1e-6 ? 1 : range / 4;

    return LineChartData(
      minX: minX,
      maxX: maxX,
      minY: chartMinY,
      maxY: chartMaxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
          strokeWidth: 1,
          dashArray: const [6, 6],
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.3),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          gradient: LinearGradient(colors: gradientColors),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: areaColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final point = dataPoints[index];
              final bool isMin = point == minPoint;
              final bool isMax = point == maxPoint;
              final Color color = isMax
                  ? AppColors.success
                  : isMin
                  ? AppColors.error
                  : AppColors.chartGradientEnd;
              return FlDotCirclePainter(
                radius: 5,
                color: color,
                strokeColor: AppColors.white,
                strokeWidth: 2,
              );
            },
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final point = dataPoints[spot.spotIndex];
              return LineTooltipItem(
                '${_formatDate(point.date)}\n${_formatValue(point.value)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          if (goalValue != null)
            HorizontalLine(
              y: goalValue!,
              dashArray: const [8, 6],
              color: AppColors.warning.withValues(alpha: 0.9),
              strokeWidth: 2,
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 8),
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
                labelResolver: (_) => 'Meta',
              ),
            ),
        ],
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              final int index = value.round();
              if (index == 0) {
                return _TitleLabel(_formatDate(dataPoints.first.date));
              }
              if (index == meta.max.round()) {
                return _TitleLabel(_formatDate(dataPoints.last.date));
              }
              if (dataPoints.length > 4 && index == (meta.max / 2).round()) {
                return _TitleLabel(
                  _formatDate(dataPoints[dataPoints.length ~/ 2].date),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (value, meta) {
              const double epsilon = 0.01;
              if ((value - actualMinValue).abs() < epsilon) {
                return _TitleLabel(_formatValue(actualMinValue));
              }
              if ((value - actualMaxValue).abs() < epsilon) {
                return _TitleLabel(_formatValue(actualMaxValue));
              }
              if (goalValue != null && (value - goalValue!).abs() < epsilon) {
                return _TitleLabel(_formatValue(goalValue!));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _DataPoint {
  _DataPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class _TitleLabel extends StatelessWidget {
  const _TitleLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}
