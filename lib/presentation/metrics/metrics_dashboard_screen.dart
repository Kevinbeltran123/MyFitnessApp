import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/metrics/add_measurement_screen.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/bmi_calculator.dart';
import 'package:my_fitness_tracker/presentation/metrics/models/metric_insights.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/comparison_card.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/metric_chart.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/metric_range_selector.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/trend_indicator.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/quick_weight_logger_dialog.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';

enum _MetricContextAction { edit, delete }

/// Dashboard screen for body metrics tracking.
///
/// Features:
/// - Latest measurements display
/// - Weight/body composition charts
/// - BMI calculator
/// - Add new measurement button
class MetricsDashboardScreen extends ConsumerWidget {
  const MetricsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(filteredMetricsProvider);
    final latestMetricAsync = ref.watch(latestBodyMetricProvider);
    final profileAsync = ref.watch(metabolicProfileProvider);
    final MetricDateRange? currentRange = ref
        .watch(selectedMetricRangeProvider)
        .toDateRange(DateTime.now());
    final AsyncValue<WorkoutStats?> workoutStatsAsync = currentRange == null
        ? const AsyncValue<WorkoutStats?>.data(null)
        : ref
              .watch(workoutStatsProvider(currentRange))
              .whenData((value) => value);
    final AsyncValue<List<MuscleGroupStat>?> muscleStatsAsync =
        currentRange == null
        ? const AsyncValue<List<MuscleGroupStat>?>.data(null)
        : ref
              .watch(muscleGroupStatsProvider(currentRange))
              .whenData((value) => value);
    final AsyncValue<double?> consistencyAsync = currentRange == null
        ? const AsyncValue<double?>.data(null)
        : ref
              .watch(consistencyMetricsProvider(currentRange))
              .whenData((value) => value);
    final rangePreset = ref.watch(selectedMetricRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medidas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _openMeasurementForm(context, ref),
            tooltip: 'Agregar medida',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showQuickWeightLoggerDialog(context, ref);
          if (result == null) return;
          if (!context.mounted) return;
          AppSnackBar.showSuccess(
            context,
            'Peso registrado: ${result.toStringAsFixed(1)} kg',
          );
          ref.invalidate(bodyMetricsProvider);
          ref.invalidate(filteredMetricsProvider);
          ref.invalidate(latestBodyMetricProvider);
        },
        icon: const Icon(Icons.monitor_weight_outlined),
        label: const Text('Peso rápido'),
      ),
      body: SafeArea(
        child: metricsAsync.when(
          loading: () => const LoadingStateWidget(),
          error: (error, stack) => ErrorStateWidget(
            title: 'Error al cargar tus medidas',
            message: error.toString(),
            onRetry: () {
              ref.invalidate(bodyMetricsProvider);
              ref.invalidate(filteredMetricsProvider);
              ref.invalidate(latestBodyMetricProvider);
            },
          ),
          data: (metrics) {
            if (metrics.isEmpty) {
              return rangePreset == MetricRangePreset.all
                  ? _buildEmptyState(context)
                  : _buildEmptyRangeState(context, rangePreset);
            }

            final sortedMetrics = [...metrics]
              ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
            final comparisonMetrics = _buildComparisonMetrics(sortedMetrics);
            final trendInsightsList = _buildTrendInsights(sortedMetrics);
            final profile = profileAsync.value;

            final analyticsKey = ValueKey(
              '${rangePreset.name}-${sortedMetrics.length > 1 ? sortedMetrics.last.recordedAt.millisecondsSinceEpoch : sortedMetrics.length}',
            );

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(bodyMetricsProvider);
                ref.invalidate(latestBodyMetricProvider);
                ref.invalidate(filteredMetricsProvider);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: analyticsKey,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Periodo de análisis',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const MetricRangeSelector(),
                      const SizedBox(height: 20),

                      if (comparisonMetrics.isNotEmpty) ...[
                        ComparisonCard(metrics: comparisonMetrics),
                        const SizedBox(height: 20),
                      ],

                      ..._buildWorkoutSummarySection(workoutStatsAsync),
                      ..._buildConsistencySection(consistencyAsync),

                      if (trendInsightsList.isNotEmpty) ...[
                        Text(
                          'Indicadores de tendencia',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...trendInsightsList.map(
                          (insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TrendIndicator(insights: insight),
                          ),
                        ),
                      ],

                      // Latest measurement card
                      latestMetricAsync.when(
                        data: (latest) => latest != null
                            ? _buildLatestMeasurementCard(
                                context,
                                theme,
                                latest,
                                profileAsync.value,
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      // BMI Calculator
                      profileAsync.when(
                        data: (profile) => profile != null
                            ? BMICalculator(
                                profile: profile,
                                latestWeight:
                                    latestMetricAsync.value?.weightKg ?? 0,
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      ..._buildMuscleGroupSection(theme, muscleStatsAsync),

                      // Weight chart
                      Text(
                        'Progreso de Peso',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MetricChart(
                        metrics: metrics,
                        metricType: MetricType.weight,
                        goalValue: profile?.weightKg,
                      ),
                      const SizedBox(height: 24),

                      // Body fat chart (if available)
                      if (metrics.any((m) => m.bodyFatPercentage != null)) ...[
                        Text(
                          'Grasa Corporal',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MetricChart(
                          metrics: metrics,
                          metricType: MetricType.bodyFat,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Muscle mass chart (if available)
                      if (metrics.any((m) => m.muscleMassKg != null)) ...[
                        Text(
                          'Masa Muscular',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MetricChart(
                          metrics: metrics,
                          metricType: MetricType.muscleMass,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Measurement history
                      Text(
                        'Historial',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...metrics
                          .take(10)
                          .map(
                            (metric) =>
                                _buildHistoryItem(context, theme, metric, ref),
                          ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLatestMeasurementCard(
    BuildContext context,
    ThemeData theme,
    BodyMetric metric,
    MetabolicProfile? profile,
  ) {
    final bmi = profile != null
        ? (metric.weightKg /
              ((profile.heightCm / 100) * (profile.heightCm / 100)))
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.grayGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Última Medida',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(metric.recordedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatBadge(
                  theme,
                  label: 'Peso',
                  value: '${metric.weightKg.toStringAsFixed(1)} kg',
                ),
              ),
              if (metric.bodyFatPercentage != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBadge(
                    theme,
                    label: 'Grasa',
                    value: '${metric.bodyFatPercentage!.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (metric.muscleMassKg != null)
                Expanded(
                  child: _buildStatBadge(
                    theme,
                    label: 'Músculo',
                    value: '${metric.muscleMassKg!.toStringAsFixed(1)} kg',
                  ),
                ),
              if (bmi != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBadge(
                    theme,
                    label: 'IMC',
                    value: bmi.toStringAsFixed(1),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
    ThemeData theme, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    ThemeData theme,
    BodyMetric metric,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: () => _onMetricLongPress(context, ref, metric),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textTertiary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(metric.recordedAt),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${metric.weightKg.toStringAsFixed(1)} kg',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (metric.bodyFatPercentage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${metric.bodyFatPercentage!.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onMetricLongPress(
    BuildContext context,
    WidgetRef ref,
    BodyMetric metric,
  ) async {
    final action = await showModalBottomSheet<_MetricContextAction>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar medida'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_MetricContextAction.edit),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Eliminar medida'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_MetricContextAction.delete),
              ),
            ],
          ),
        );
      },
    );

    if (action == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (action == _MetricContextAction.edit) {
      await _openMeasurementForm(context, ref, metric: metric);
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar medida'),
          content: const Text(
            'Esta acción no se puede deshacer. ¿Deseas eliminar la medición seleccionada?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (confirm != true) {
      return;
    }

    try {
      final repository = await ref.read(metricsRepositoryProvider.future);
      await repository.deleteMetric(metric.id);
      if (!context.mounted) return;
      _refreshMetricProviders(ref);
      AppSnackBar.showSuccess(context, 'Medición eliminada');
    } catch (error) {
      if (!context.mounted) return;
      AppSnackBar.showError(context, 'No pudimos eliminar la medición: $error');
    }
  }

  void _refreshMetricProviders(WidgetRef ref) {
    ref.invalidate(bodyMetricsProvider);
    ref.invalidate(filteredMetricsProvider);
    ref.invalidate(latestBodyMetricProvider);
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.monitor_weight_outlined,
      title: 'Aún no tienes medidas',
      message:
          'Agrega tu primera medición para visualizar tus tendencias y estadísticas.',
      primaryLabel: 'Agregar medida',
      onPrimaryTap: () => _openMeasurementForm(context, null),
    );
  }

  Widget _buildEmptyRangeState(BuildContext context, MetricRangePreset preset) {
    return EmptyStateWidget(
      icon: Icons.timeline_outlined,
      title: 'Sin datos en ${preset.label.toLowerCase()}',
      message:
          'Registra nuevas mediciones o selecciona otro periodo para continuar analizando tu progreso.',
    );
  }

  Future<void> _openMeasurementForm(
    BuildContext context,
    WidgetRef? ref, {
    BodyMetric? metric,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMeasurementScreen(initialMetric: metric),
      ),
    );
    if (ref != null) {
      _refreshMetricProviders(ref);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<ComparisonMetricData> _buildComparisonMetrics(List<BodyMetric> metrics) {
    if (metrics.length < 2) {
      return const [];
    }
    final BodyMetric first = metrics.first;
    final BodyMetric last = metrics.last;

    final List<ComparisonMetricData> data = [];

    final double weightDelta = last.weightKg - first.weightKg;
    data.add(
      ComparisonMetricData(
        label: 'Peso',
        unit: 'kg',
        delta: weightDelta,
        percentChange: first.weightKg > 0
            ? (weightDelta / first.weightKg) * 100
            : null,
        average: _average(metrics.map((m) => m.weightKg).toList()),
        trend: _trendFromDelta(weightDelta),
      ),
    );

    final double? firstBodyFat = _firstNonNull(
      metrics,
      (metric) => metric.bodyFatPercentage,
    );
    final double? lastBodyFat = _lastNonNull(
      metrics,
      (metric) => metric.bodyFatPercentage,
    );
    if (firstBodyFat != null && lastBodyFat != null) {
      final double delta = lastBodyFat - firstBodyFat;
      data.add(
        ComparisonMetricData(
          label: 'Grasa',
          unit: '%',
          delta: delta,
          percentChange: firstBodyFat > 0 ? (delta / firstBodyFat) * 100 : null,
          average: _average(
            metrics
                .where((metric) => metric.bodyFatPercentage != null)
                .map((metric) => metric.bodyFatPercentage!)
                .toList(),
          ),
          trend: _trendFromDelta(delta),
        ),
      );
    } else {
      data.add(
        const ComparisonMetricData(
          label: 'Grasa',
          unit: '%',
          delta: null,
          percentChange: null,
          average: null,
          trend: MetricTrend.stable,
        ),
      );
    }

    final double? firstMuscle = _firstNonNull(
      metrics,
      (metric) => metric.muscleMassKg,
    );
    final double? lastMuscle = _lastNonNull(
      metrics,
      (metric) => metric.muscleMassKg,
    );
    if (firstMuscle != null && lastMuscle != null) {
      final double delta = lastMuscle - firstMuscle;
      data.add(
        ComparisonMetricData(
          label: 'Músculo',
          unit: 'kg',
          delta: delta,
          percentChange: firstMuscle > 0 ? (delta / firstMuscle) * 100 : null,
          average: _average(
            metrics
                .where((metric) => metric.muscleMassKg != null)
                .map((metric) => metric.muscleMassKg!)
                .toList(),
          ),
          trend: _trendFromDelta(delta),
        ),
      );
    } else {
      data.add(
        const ComparisonMetricData(
          label: 'Músculo',
          unit: 'kg',
          delta: null,
          percentChange: null,
          average: null,
          trend: MetricTrend.stable,
        ),
      );
    }

    return data;
  }

  List<TrendInsights> _buildTrendInsights(List<BodyMetric> metrics) {
    final List<TrendInsights> insights = [];
    final List<double> weightPoints = metrics
        .map((metric) => metric.weightKg)
        .toList();
    final TrendInsights? weightTrend = _createTrendInsight(
      'Peso',
      'kg',
      weightPoints,
    );
    if (weightTrend != null) {
      insights.add(weightTrend);
    }

    final List<double> bodyFatPoints = metrics
        .where((metric) => metric.bodyFatPercentage != null)
        .map((metric) => metric.bodyFatPercentage!)
        .toList();
    final TrendInsights? bodyFatTrend = _createTrendInsight(
      'Grasa corporal',
      '%',
      bodyFatPoints,
    );
    if (bodyFatTrend != null) {
      insights.add(bodyFatTrend);
    }

    final List<double> musclePoints = metrics
        .where((metric) => metric.muscleMassKg != null)
        .map((metric) => metric.muscleMassKg!)
        .toList();
    final TrendInsights? muscleTrend = _createTrendInsight(
      'Masa muscular',
      'kg',
      musclePoints,
    );
    if (muscleTrend != null) {
      insights.add(muscleTrend);
    }

    return insights;
  }

  TrendInsights? _createTrendInsight(
    String title,
    String unit,
    List<double> points,
  ) {
    if (points.length < 2) {
      return null;
    }
    final List<double> trimmed = points.length > 12
        ? points.sublist(points.length - 12)
        : points;
    final double slope = _calculateSlope(trimmed);
    final MetricTrend trend = _trendFromSlope(slope);
    final double projected = trimmed.last + slope;
    return TrendInsights(
      title: title,
      points: trimmed,
      slope: slope,
      latestValue: trimmed.last,
      projectedValue: projected,
      trend: trend,
      unit: unit,
    );
  }

  double _calculateSlope(List<double> values) {
    final int n = values.length;
    final List<double> xs = List<double>.generate(
      n,
      (index) => index.toDouble(),
    );
    final double meanX = xs.reduce((value, element) => value + element) / n;
    final double meanY = values.reduce((value, element) => value + element) / n;

    double numerator = 0;
    double denominator = 0;

    for (int i = 0; i < n; i += 1) {
      final double dx = xs[i] - meanX;
      numerator += dx * (values[i] - meanY);
      denominator += dx * dx;
    }
    if (denominator == 0) {
      return 0;
    }
    return numerator / denominator;
  }

  MetricTrend _trendFromDelta(double delta, {double threshold = 0.05}) {
    if (delta.abs() <= threshold) {
      return MetricTrend.stable;
    }
    return delta > 0 ? MetricTrend.up : MetricTrend.down;
  }

  MetricTrend _trendFromSlope(double slope, {double threshold = 0.01}) {
    if (slope.abs() <= threshold) {
      return MetricTrend.stable;
    }
    return slope > 0 ? MetricTrend.up : MetricTrend.down;
  }

  double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    final double sum = values.reduce((value, element) => value + element);
    return sum / values.length;
  }

  double? _firstNonNull(
    List<BodyMetric> metrics,
    double? Function(BodyMetric metric) selector,
  ) {
    for (final metric in metrics) {
      final value = selector(metric);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  double? _lastNonNull(
    List<BodyMetric> metrics,
    double? Function(BodyMetric metric) selector,
  ) {
    for (final metric in metrics.reversed) {
      final value = selector(metric);
      if (value != null) {
        return value;
      }
    }
    return null;
  }
}

List<Widget> _buildWorkoutSummarySection(AsyncValue<WorkoutStats?> statsAsync) {
  return statsAsync.when(
    data: (stats) {
      if (stats == null) {
        return const <Widget>[];
      }
      return <Widget>[
        _WorkoutSummaryCard(stats: stats),
        const SizedBox(height: 20),
      ];
    },
    loading: () => const <Widget>[],
    error: (_, __) => const <Widget>[],
  );
}

List<Widget> _buildConsistencySection(AsyncValue<double?> consistencyAsync) {
  return consistencyAsync.when(
    data: (percentage) {
      if (percentage == null) {
        return const <Widget>[];
      }
      return <Widget>[
        _ConsistencyBanner(percentage: percentage),
        const SizedBox(height: 20),
      ];
    },
    loading: () => const <Widget>[],
    error: (_, __) => const <Widget>[],
  );
}

List<Widget> _buildMuscleGroupSection(
  ThemeData theme,
  AsyncValue<List<MuscleGroupStat>?> statsAsync,
) {
  return statsAsync.when(
    data: (stats) {
      if (stats == null || stats.isEmpty) {
        return const <Widget>[];
      }
      return <Widget>[
        Text(
          'Volumen por grupo muscular',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _MuscleGroupBreakdown(stats: stats),
        const SizedBox(height: 24),
      ];
    },
    loading: () => const <Widget>[],
    error: (_, __) => const <Widget>[],
  );
}

class _WorkoutSummaryCard extends StatelessWidget {
  const _WorkoutSummaryCard({required this.stats});

  final WorkoutStats stats;

  @override
  Widget build(BuildContext context) {
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
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          _SummaryStat(
            label: 'Volumen total',
            value: '${stats.totalVolume.toStringAsFixed(0)} kg·reps',
          ),
          _SummaryStat(label: 'Sets', value: stats.totalSets.toString()),
          _SummaryStat(
            label: 'Sesiones',
            value: stats.totalSessions.toString(),
          ),
          _SummaryStat(
            label: 'Volumen promedio',
            value: stats.averageVolumePerSession.toStringAsFixed(0),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsistencyBanner extends StatelessWidget {
  const _ConsistencyBanner({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double normalized = (percentage.clamp(0, 100)) / 100;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consistencia',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: normalized,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppColors.accentBlue.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}% de días activos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleGroupBreakdown extends StatelessWidget {
  const _MuscleGroupBreakdown({required this.stats});

  final List<MuscleGroupStat> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double maxVolume = stats.fold<double>(
      0,
      (previousValue, element) =>
          element.volume > previousValue ? element.volume : previousValue,
    );

    final Iterable<MuscleGroupStat> topStats = stats.take(6);

    return Column(
      children: topStats
          .map((stat) {
            final double progress = maxVolume == 0
                ? 0
                : stat.volume / maxVolume;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.group,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0, 1),
                            minHeight: 8,
                            backgroundColor: AppColors.accentBlue.withValues(
                              alpha: 0.15,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${stat.percentage.toStringAsFixed(1)} %',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
