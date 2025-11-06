import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_controller.dart';
import 'package:my_fitness_tracker/presentation/analytics/widgets/volume_bar_chart.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';

/// Segment-based volume insights with chart, selector, and summary.
class VolumeInsights extends ConsumerWidget {
  const VolumeInsights({
    super.key,
    this.range,
    this.enableRefresh = true,
    this.padding = const EdgeInsets.all(16),
  });

  final MetricDateRange? range;
  final bool enableRefresh;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget content = _VolumeInsightsBody(range: range, padding: padding);

    if (!enableRefresh) {
      return content;
    }

    return RefreshIndicator(
      onRefresh: () async {
        final aggregation = ref.read(selectedVolumeAggregationProvider);
        final params = _buildVolumeParams(range, aggregation);
        ref.invalidate(volumeSeriesByParamsProvider(params));
        ref.invalidate(volumeSeriesProvider);
      },
      child: content,
    );
  }
}

class _VolumeInsightsBody extends ConsumerWidget {
  const _VolumeInsightsBody({required this.range, required this.padding});

  final MetricDateRange? range;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final aggregation = ref.watch(selectedVolumeAggregationProvider);
    final params = _buildVolumeParams(range, aggregation);

    final AsyncValue<VolumeSeries> seriesAsync = ref.watch(
      volumeSeriesByParamsProvider(params),
    );

    return ListView(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Text(
          'Selector de periodo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<VolumeAggregation>(
          segments: VolumeAggregation.values
              .map(
                (aggregation) => ButtonSegment<VolumeAggregation>(
                  value: aggregation,
                  label: Text(aggregation.label),
                ),
              )
              .toList(growable: false),
          selected: <VolumeAggregation>{aggregation},
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              ref.read(selectedVolumeAggregationProvider.notifier).state =
                  selection.first;
            }
          },
        ),
        const SizedBox(height: 24),
        seriesAsync.when(
          loading: () =>
              const LoadingStateWidget(message: 'Calculando tu volumen...'),
          error: (error, _) => ErrorStateWidget(
            title: 'No pudimos cargar el volumen',
            message: error.toString(),
            onRetry: () => ref.invalidate(volumeSeriesByParamsProvider(params)),
          ),
          data: (series) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VolumeBarChart(series: series),
              const SizedBox(height: 16),
              _TotalVolumeCard(series: series),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalVolumeCard extends StatelessWidget {
  const _TotalVolumeCard({required this.series});

  final VolumeSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String headline = series.aggregation == VolumeAggregation.weekly
        ? 'Últimas ${series.points.length} semanas'
        : 'Últimos ${series.points.length} meses';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.subtleGrayGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatVolume(series.totalVolume)} kg',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Volumen total acumulado en el periodo seleccionado',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
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

VolumeSeriesParams _buildVolumeParams(
  MetricDateRange? range,
  VolumeAggregation aggregation,
) {
  final MetricDateRange effectiveRange = range ?? _defaultVolumeRange();
  final DateTime anchor = effectiveRange.end;
  final int periods = _calculatePeriods(effectiveRange, aggregation);
  return VolumeSeriesParams(
    aggregation: aggregation,
    anchor: anchor,
    periods: periods,
  );
}

MetricDateRange _defaultVolumeRange() {
  final DateTime now = DateTime.now();
  final DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final DateTime start = end
      .subtract(const Duration(days: 7 * 11))
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  return MetricDateRange(start: start, end: end);
}

int _calculatePeriods(MetricDateRange range, VolumeAggregation aggregation) {
  final int days = range.end.difference(range.start).inDays + 1;
  switch (aggregation) {
    case VolumeAggregation.weekly:
      int weeks = (days / 7).ceil();
      if (weeks < 1) weeks = 1;
      if (weeks > 52) weeks = 52;
      return weeks;
    case VolumeAggregation.monthly:
      final int yearDelta = range.end.year - range.start.year;
      final int monthDelta = range.end.month - range.start.month;
      int months = (yearDelta * 12) + monthDelta + 1;
      if (months < 1) months = 1;
      if (months > 24) months = 24;
      return months;
  }
}
