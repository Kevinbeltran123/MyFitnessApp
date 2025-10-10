import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/infrastructure/isar/isar_providers.dart';
import 'package:my_fitness_tracker/infrastructure/metrics/metrics_repository_isar.dart';

/// Predefined range presets for filtering metrics within the dashboard.
enum MetricRangePreset {
  last7Days,
  last30Days,
  last90Days,
  all,
}

extension MetricRangePresetX on MetricRangePreset {
  String get label {
    switch (this) {
      case MetricRangePreset.last7Days:
        return '7 días';
      case MetricRangePreset.last30Days:
        return '30 días';
      case MetricRangePreset.last90Days:
        return '90 días';
      case MetricRangePreset.all:
        return 'Todo';
    }
  }

  Duration? get duration {
    switch (this) {
      case MetricRangePreset.last7Days:
        return const Duration(days: 7);
      case MetricRangePreset.last30Days:
        return const Duration(days: 30);
      case MetricRangePreset.last90Days:
        return const Duration(days: 90);
      case MetricRangePreset.all:
        return null;
    }
  }

  MetricDateRange? toDateRange(DateTime now) {
    final duration = this.duration;
    if (duration == null) {
      return null;
    }
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = end.subtract(duration).copyWith(hour: 0, minute: 0, second: 0);
    return MetricDateRange(start: start, end: end);
  }
}

/// Provider for the metrics repository
final metricsRepositoryProvider =
    FutureProvider<MetricsRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return MetricsRepositoryIsar(isar);
});

/// Provider for watching all body metrics
final bodyMetricsProvider = StreamProvider<List<BodyMetric>>((ref) async* {
  final repository = await ref.watch(metricsRepositoryProvider.future);
  yield* repository.watchMetrics();
});

/// Provider for latest body metric
final latestBodyMetricProvider = FutureProvider<BodyMetric?>((ref) async {
  final repository = await ref.watch(metricsRepositoryProvider.future);
  return repository.latestMetric();
});

/// Provider for metabolic profile
final metabolicProfileProvider =
    FutureProvider<MetabolicProfile?>((ref) async {
  final repository = await ref.watch(metricsRepositoryProvider.future);
  return repository.loadMetabolicProfile();
});

/// Selected preset for filtering metrics in the dashboard.
final selectedMetricRangeProvider =
    StateProvider<MetricRangePreset>((ref) => MetricRangePreset.last30Days);

/// Provider exposing metrics filtered by the currently selected range.
final filteredMetricsProvider =
    StreamProvider<List<BodyMetric>>((ref) async* {
  final repository = await ref.watch(metricsRepositoryProvider.future);
  final preset = ref.watch(selectedMetricRangeProvider);
  final now = DateTime.now();
  final range = preset.toDateRange(now);

  if (range == null) {
    yield* repository.watchMetrics();
  } else {
    yield* repository.watchMetrics(range: range);
  }
});
