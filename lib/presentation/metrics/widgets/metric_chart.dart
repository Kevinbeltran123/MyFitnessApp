import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Enum for metric types to display in charts
enum MetricType {
  weight,
  bodyFat,
  muscleMass,
}

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

    final _DataPoint minPoint = dataPoints.reduce(
      (value, element) => element.value < value.value ? element : value,
    );
    final _DataPoint maxPoint = dataPoints.reduce(
      (value, element) => element.value > value.value ? element : value,
    );

    final double minValue =
        dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final double maxValue =
        dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final double rawRange = maxValue - minValue;
    final double padding = (rawRange == 0 ? 1 : rawRange) * 0.1;
    final double adjustedMin = minValue - padding;
    final double adjustedMax = maxValue + padding;

    const double chartHeight = 160;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            height: chartHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final Size canvasSize =
                    Size(constraints.maxWidth, chartHeight);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: canvasSize,
                      painter: _SimpleLinePainter(
                        dataPoints: dataPoints,
                        minValue: adjustedMin,
                        maxValue: adjustedMax,
                        goalValue: goalValue,
                      ),
                    ),
                    ...dataPoints.map((point) {
                      final offset = _resolvePointOffset(
                        point: point,
                        allPoints: dataPoints,
                        canvasSize: canvasSize,
                        minValue: adjustedMin,
                        maxValue: adjustedMax,
                      );
                      final bool isMin = point == minPoint;
                      final bool isMax = point == maxPoint;
                      final Color pointColor = isMax
                          ? AppColors.success
                          : isMin
                              ? AppColors.error
                              : AppColors.chartGradientEnd;

                      return Positioned(
                        left: offset.dx - 6,
                        top: offset.dy - 6,
                        child: Tooltip(
                          message:
                              '${_formatDate(point.date)} · ${_formatValue(point.value)}',
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: pointColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
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

  Offset _resolvePointOffset({
    required _DataPoint point,
    required List<_DataPoint> allPoints,
    required Size canvasSize,
    required double minValue,
    required double maxValue,
  }) {
    final int index = allPoints.indexOf(point);
    final double x = allPoints.length == 1
        ? canvasSize.width / 2
        : (index / (allPoints.length - 1)) * canvasSize.width;
    final double range = (maxValue - minValue).abs() < 1e-6
        ? 1
        : (maxValue - minValue);
    final double normalized =
        ((point.value - minValue) / range).clamp(0, 1).toDouble();
    final double y = canvasSize.height - (normalized * canvasSize.height);
    return Offset(x, y);
  }
}

class _DataPoint {
  _DataPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class _SimpleLinePainter extends CustomPainter {
  _SimpleLinePainter({
    required this.dataPoints,
    required this.minValue,
    required this.maxValue,
    this.goalValue,
  });

  final List<_DataPoint> dataPoints;
  final double minValue;
  final double maxValue;
  final double? goalValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) {
      return;
    }

    final double range = (maxValue - minValue).abs() < 1e-6
        ? 1
        : (maxValue - minValue);

    final Paint linePaint = Paint()
      ..color = AppColors.accentBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentBlue.withValues(alpha: 0.3),
          AppColors.accentBlue.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final Path fillPath = Path();

    for (int i = 0; i < dataPoints.length; i += 1) {
      final double x = dataPoints.length == 1
          ? size.width / 2
          : (i / (dataPoints.length - 1)) * size.width;
      final double normalized =
          ((dataPoints[i].value - minValue) / range).clamp(0, 1).toDouble();
      final double y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, linePaint);

    if (goalValue != null &&
        goalValue! >= minValue &&
        goalValue! <= maxValue) {
      final double normalizedGoal =
          ((goalValue! - minValue) / range).clamp(0, 1).toDouble();
      final double yGoal = size.height - (normalizedGoal * size.height);
      final Paint goalPaint = Paint()
        ..color = AppColors.warning.withValues(alpha: 0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, yGoal), Offset(size.width, yGoal), goalPaint);
    }
  }

  @override
  bool shouldRepaint(_SimpleLinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.goalValue != goalValue;
  }
}
