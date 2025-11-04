import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';

/// Currently selected aggregation for the volume chart.
final selectedVolumeAggregationProvider =
    StateProvider<VolumeAggregation>((ref) => VolumeAggregation.weekly);

/// Provides a volume series for the selected aggregation, anchored on today.
final volumeSeriesProvider = FutureProvider<VolumeSeries>((ref) async {
  final aggregation = ref.watch(selectedVolumeAggregationProvider);
  final service = await ref.watch(analyticsServiceProvider.future);
  return service.buildVolumeSeries(
    aggregation: aggregation,
    anchor: DateTime.now(),
    periods: 12,
  );
});

/// Parameter bag for requesting volume series data.
class VolumeSeriesParams {
  const VolumeSeriesParams({
    required this.aggregation,
    required this.anchor,
    required this.periods,
  });

  final VolumeAggregation aggregation;
  final DateTime anchor;
  final int periods;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VolumeSeriesParams &&
        other.aggregation == aggregation &&
        other.anchor == anchor &&
        other.periods == periods;
  }

  @override
  int get hashCode => Object.hash(aggregation, anchor, periods);
}

/// Provides a volume series using custom parameters (useful for global filters).
final volumeSeriesByParamsProvider =
    FutureProvider.family<VolumeSeries, VolumeSeriesParams>((ref, params) async {
  final service = await ref.watch(analyticsServiceProvider.future);
  return service.buildVolumeSeries(
    aggregation: params.aggregation,
    anchor: params.anchor,
    periods: params.periods,
  );
});

extension VolumeAggregationLabels on VolumeAggregation {
  String get label {
    switch (this) {
      case VolumeAggregation.weekly:
        return 'Semanal';
      case VolumeAggregation.monthly:
        return 'Mensual';
    }
  }
}

/// Aggregated summary of muscle distribution analytics.
class MuscleDistributionSummary {
  const MuscleDistributionSummary({
    required this.stats,
    required this.totalVolume,
    required this.dominantGroup,
    required this.imbalanceGap,
  });

  final List<MuscleGroupStat> stats;
  final double totalVolume;
  final MuscleGroupStat? dominantGroup;
  final double imbalanceGap;

  bool get hasSevereImbalance => imbalanceGap >= 30;
}

/// Provides muscle distribution stats for a custom range and highlights
/// potential imbalances (>=30% gap between top and lowest groups).
final muscleDistributionProvider = FutureProvider.family<
    MuscleDistributionSummary,
    MetricDateRange>((ref, range) async {
  final service = await ref.watch(analyticsServiceProvider.future);
  final List<MuscleGroupStat> stats = await service.getMuscleGroupStats(range);
  if (stats.isEmpty) {
    return const MuscleDistributionSummary(
      stats: <MuscleGroupStat>[],
      totalVolume: 0,
      dominantGroup: null,
      imbalanceGap: 0,
    );
  }

  stats.sort((a, b) => b.percentage.compareTo(a.percentage));
  final MuscleGroupStat dominant = stats.first;
  final MuscleGroupStat lowest = stats.last;
  final double gap = dominant.percentage - lowest.percentage;
  final double total = stats.fold<double>(0, (double acc, MuscleGroupStat stat) {
    return acc + stat.volume;
  });

  return MuscleDistributionSummary(
    stats: List<MuscleGroupStat>.unmodifiable(stats),
    totalVolume: total,
    dominantGroup: dominant,
    imbalanceGap: gap,
  );
});

/// Parameters for requesting training heatmap data.
class TrainingHeatmapParams {
  const TrainingHeatmapParams({
    required this.anchor,
    required this.days,
  });

  final DateTime anchor;
  final int days;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingHeatmapParams &&
        other.anchor == anchor &&
        other.days == days;
  }

  @override
  int get hashCode => Object.hash(anchor, days);
}

/// Provides training activity data for heatmap visualisations.
final trainingHeatmapProvider = FutureProvider.family<
    TrainingHeatmapData,
    TrainingHeatmapParams>((ref, params) async {
  final service = await ref.watch(analyticsServiceProvider.future);
  return service.buildTrainingHeatmap(
    anchor: params.anchor,
    days: params.days,
  );
});
