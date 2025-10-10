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
  });

  final List<BodyMetric> metrics;
  final MetricType metricType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter and extract data points
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

    final minValue = dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxValue = dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range * 0.1; // 10% padding

    return Container(
      height: 220,
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
          // Chart title and current value
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.chartGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatValue(dataPoints.first.value),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Simple line chart
          Expanded(
            child: CustomPaint(
              painter: _SimpleLinePainter(
                dataPoints: dataPoints,
                minValue: minValue - padding,
                maxValue: maxValue + padding,
              ),
              child: Container(),
            ),
          ),

          // Time range indicator
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(dataPoints.last.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                _formatDate(dataPoints.first.date),
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
  });

  final List<_DataPoint> dataPoints;
  final double minValue;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final range = maxValue - minValue;
    if (range == 0) return;

    // Paint for the line
    final linePaint = Paint()
      ..color = AppColors.accentBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Paint for gradient fill
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentBlue.withValues(alpha: 0.3),
          AppColors.accentBlue.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Paint for dots
    final dotPaint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.fill;

    // Calculate points
    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final normalizedValue = (dataPoints[i].value - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw gradient fill
    canvas.drawPath(fillPath, gradientPaint);

    // Draw line
    canvas.drawPath(path, linePaint);

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_SimpleLinePainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue;
  }
}
