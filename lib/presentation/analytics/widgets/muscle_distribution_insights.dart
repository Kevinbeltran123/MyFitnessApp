import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_controller.dart';
import 'package:my_fitness_tracker/presentation/analytics/widgets/muscle_pie_chart.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';

/// Shows muscle distribution analytics with pie chart and imbalance warnings.
class MuscleDistributionInsights extends ConsumerWidget {
  const MuscleDistributionInsights({
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
    final MetricDateRange targetRange = range ?? _defaultRange();
    final Widget content = _MuscleDistributionBody(
      range: targetRange,
      padding: padding,
    );

    if (!enableRefresh) {
      return content;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(muscleDistributionProvider(targetRange));
      },
      child: content,
    );
  }

  MetricDateRange _defaultRange() {
    final DateTime now = DateTime.now();
    final DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final DateTime start = end.subtract(const Duration(days: 29)).copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    return MetricDateRange(start: start, end: end);
  }
}

class _MuscleDistributionBody extends ConsumerWidget {
  const _MuscleDistributionBody({required this.range, required this.padding});

  final MetricDateRange range;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AsyncValue<MuscleDistributionSummary> summaryAsync = ref.watch(
      muscleDistributionProvider(range),
    );

    return ListView(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Text(
          'Periodo analizado',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        _RangeCard(range: range),
        const SizedBox(height: 24),
        summaryAsync.when(
          loading: () => const LoadingStateWidget(
            message: 'Analizando tus grupos musculares...',
          ),
          error: (error, _) => ErrorStateWidget(
            title: 'No pudimos cargar la distribución',
            message: error.toString(),
            onRetry: () => ref.invalidate(muscleDistributionProvider(range)),
          ),
          data: (summary) {
            if (summary.stats.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.self_improvement_outlined,
                title: 'Sin datos suficientes',
                message:
                    'Registra sesiones con peso para ver cómo se reparte tu volumen por grupos musculares.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MusclePieChart(
                  stats: summary.stats,
                  totalVolume: summary.totalVolume,
                ),
                const SizedBox(height: 16),
                if (summary.hasSevereImbalance)
                  _ImbalanceCard(summary: summary),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RangeCard extends StatelessWidget {
  const _RangeCard({required this.range});

  final MetricDateRange range;

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
          const Icon(Icons.calendar_today_outlined, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Últimos ${_rangeLengthInDays(range)} días',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_formatDate(range.start)} – ${_formatDate(range.end)}',
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

  static int _rangeLengthInDays(MetricDateRange range) {
    return range.end.difference(range.start).inDays + 1;
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _ImbalanceCard extends StatelessWidget {
  const _ImbalanceCard({required this.summary});

  final MuscleDistributionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MuscleGroupStat? dominant = summary.dominantGroup;
    if (dominant == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desbalance muscular detectado',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dominant.group} concentra ${dominant.percentage.toStringAsFixed(1)}% del volumen. Considera añadir trabajo para grupos rezagados.',
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
}
