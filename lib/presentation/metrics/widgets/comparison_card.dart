import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/presentation/metrics/models/metric_insights.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class ComparisonCard extends StatelessWidget {
  const ComparisonCard({
    super.key,
    required this.metrics,
  });

  final List<ComparisonMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.15),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparativas del periodo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: metrics.asMap().entries.map((entry) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 250 + (entry.key * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 16),
                      child: child,
                    ),
                  );
                },
                child: _ComparisonItem(metric: entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ComparisonItem extends StatelessWidget {
  const _ComparisonItem({required this.metric});

  final ComparisonMetricData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color trendColor = _trendColor(metric.trend);
    final IconData trendIcon = _trendIcon(metric.trend);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(
                trendIcon,
                color: trendColor,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (metric.hasValue) ...[
            Text(
              _formatDelta(metric.delta!, metric.unit),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (metric.percentChange != null)
              Text(
                _formatPercent(metric.percentChange!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: trendColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (metric.average != null) ...[
              const SizedBox(height: 8),
              Text(
                'Promedio: ${_formatAverage(metric.average!, metric.unit)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ] else
            Text(
              'Sin datos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDelta(double value, String unit) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)} $unit';
  }

  String _formatPercent(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  String _formatAverage(double value, String unit) {
    return '${value.toStringAsFixed(1)} $unit';
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
        return Icons.north_east;
      case MetricTrend.down:
        return Icons.south_east;
      case MetricTrend.stable:
        return Icons.remove;
    }
  }
}
