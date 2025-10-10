import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/metrics/add_measurement_screen.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/bmi_calculator.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/metric_chart.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

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
    final metricsAsync = ref.watch(bodyMetricsProvider);
    final latestMetricAsync = ref.watch(latestBodyMetricProvider);
    final profileAsync = ref.watch(metabolicProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medidas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _navigateToAddMeasurement(context, ref),
            tooltip: 'Agregar medida',
          ),
        ],
      ),
      body: SafeArea(
        child: metricsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(context, error),
          data: (metrics) {
            if (metrics.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(bodyMetricsProvider);
                ref.invalidate(latestBodyMetricProvider);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    ...metrics.take(10).map(
                          (metric) => _buildHistoryItem(context, theme, metric),
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMeasurement(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Medida'),
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
        ? (metric.weightKg / ((profile.heightCm / 100) * (profile.heightCm / 100)))
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

  Widget _buildStatBadge(ThemeData theme,
      {required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
        ),
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
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aún no tienes medidas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega tu primera medida para comenzar a rastrear tu progreso',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _navigateToAddMeasurement(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Primera Medida'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar medidas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddMeasurement(BuildContext context, WidgetRef? ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMeasurementScreen(),
      ),
    ).then((_) {
      // Refresh data after returning
      if (ref != null) {
        ref.invalidate(bodyMetricsProvider);
        ref.invalidate(latestBodyMetricProvider);
      }
    });
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
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
