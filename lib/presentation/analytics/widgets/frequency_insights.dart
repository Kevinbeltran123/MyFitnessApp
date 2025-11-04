import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_controller.dart';
import 'package:my_fitness_tracker/presentation/analytics/widgets/frequency_heatmap.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';

/// Displays the training frequency heatmap with streak and highlight cards.
class FrequencyInsights extends ConsumerWidget {
  const FrequencyInsights({
    super.key,
    required this.range,
    this.enableRefresh = true,
    this.padding = const EdgeInsets.all(16),
  });

  final MetricDateRange range;
  final bool enableRefresh;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = TrainingHeatmapParams(
      anchor: range.end,
      days: range.end.difference(range.start).inDays + 1,
    );

    final Widget content = _FrequencyInsightsBody(
      params: params,
      padding: padding,
    );

    if (!enableRefresh) {
      return content;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(trainingHeatmapProvider(params));
      },
      child: content,
    );
  }
}

class _FrequencyInsightsBody extends ConsumerWidget {
  const _FrequencyInsightsBody({required this.params, required this.padding});

  final TrainingHeatmapParams params;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TrainingHeatmapData> dataAsync = ref.watch(
      trainingHeatmapProvider(params),
    );

    return ListView(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        dataAsync.when(
          loading: () => const LoadingStateWidget(
            message: 'Calculando tu consistencia...',
          ),
          error: (error, _) => ErrorStateWidget(
            title: 'No pudimos cargar la frecuencia',
            message: error.toString(),
            onRetry: () => ref.invalidate(trainingHeatmapProvider(params)),
          ),
          data: (data) {
            if (data.points.every((point) => point.sessionCount == 0)) {
              return const EmptyStateWidget(
                icon: Icons.calendar_today_outlined,
                title: 'Sin datos de entrenamientos',
                message: 'Empieza a registrar tus sesiones para ver el heatmap de consistencia.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FrequencyHeatmap(points: data.points),
                const SizedBox(height: 16),
                _StreakRow(data: data),
                const SizedBox(height: 12),
                if (data.mostProductiveDay != null)
                  _HighlightCard(point: data.mostProductiveDay!),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.data});

  final TrainingHeatmapData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.local_fire_department_outlined,
            title: 'Racha actual',
            value: '${data.currentStreak} días',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.military_tech_outlined,
            title: 'Máxima racha',
            value: '${data.longestStreak} días',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.point});

  final DailyActivityPoint point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_outline, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Día más productivo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(point.date)} • ${point.sessionCount} entrenamientos • ${_formatVolume(point.totalVolume)} kg',
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

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatVolume(double value) {
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
