import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/infrastructure/isar/isar_providers.dart';
import 'package:my_fitness_tracker/infrastructure/metrics/metrics_repository_isar.dart';

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

/// Provider for filtered metrics by date range
final metricsInRangeProvider = StreamProvider.family<List<BodyMetric>,
    MetricDateRange>((ref, range) async* {
  final repository = await ref.watch(metricsRepositoryProvider.future);
  yield* repository.watchMetrics(range: range);
});
