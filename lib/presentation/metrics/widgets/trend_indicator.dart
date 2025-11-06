import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/presentation/metrics/models/metric_insights.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class TrendIndicator extends StatelessWidget {
  const TrendIndicator({super.key, required this.insights});

  final TrendInsights insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color trendColor = _trendColor(insights.trend);
    final IconData trendIcon = _trendIcon(insights.trend);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                insights.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(trendIcon, color: trendColor),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: CustomPaint(
              painter: _TrendSparklinePainter(
                points: insights.points,
                color: trendColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _buildSummaryText(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummaryText() {
    final slope = insights.slope;
    final String direction;
    if (slope > 0) {
      direction = 'en aumento';
    } else if (slope < 0) {
      direction = 'en descenso';
    } else {
      direction = 'estable';
    }

    final buffer = StringBuffer()
      ..write('Tendencia ')
      ..write(direction)
      ..write(' con último valor ')
      ..write(insights.latestValue.toStringAsFixed(1))
      ..write(' ')
      ..write(insights.unit);

    if (insights.hasProjection) {
      buffer
        ..write(' · Proyección: ')
        ..write(insights.projectedValue!.toStringAsFixed(1))
        ..write(' ')
        ..write(insights.unit);
    }

    return buffer.toString();
  }

  Color _trendColor(MetricTrend trend) {
    switch (trend) {
      case MetricTrend.up:
        return AppColors.success;
      case MetricTrend.down:
        return AppColors.error;
      case MetricTrend.stable:
        return AppColors.warning;
    }
  }

  IconData _trendIcon(MetricTrend trend) {
    switch (trend) {
      case MetricTrend.up:
        return Icons.trending_up;
      case MetricTrend.down:
        return Icons.trending_down;
      case MetricTrend.stable:
        return Icons.trending_flat;
    }
  }
}

class _TrendSparklinePainter extends CustomPainter {
  _TrendSparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final double min = points.reduce((a, b) => a < b ? a : b);
    final double max = points.reduce((a, b) => a > b ? a : b);
    final double range = (max - min).abs() < 1e-6 ? 1 : max - min;

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    for (int i = 0; i < points.length; i += 1) {
      final double x = (i / (points.length - 1)) * size.width;
      final double normalized = (points[i] - min) / range;
      final double y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendSparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
