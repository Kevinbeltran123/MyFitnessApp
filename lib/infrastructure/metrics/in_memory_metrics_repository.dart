import 'dart:async';

import 'package:collection/collection.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';

class InMemoryMetricsRepository implements MetricsRepository {
  final List<BodyMetric> _metrics = <BodyMetric>[];
  final StreamController<List<BodyMetric>> _controller =
      StreamController<List<BodyMetric>>.broadcast();
  MetabolicProfile? _profile;

  InMemoryMetricsRepository() {
    _controller.onListen = () {
      _emit();
    };
  }

  @override
  Future<void> upsertMetric(BodyMetric metric) async {
    final int existingIndex = _metrics.indexWhere(
      (BodyMetric item) => item.id == metric.id,
    );
    if (existingIndex >= 0) {
      _metrics[existingIndex] = metric;
    } else {
      _metrics.add(metric);
    }
    _metrics.sortBy((BodyMetric m) => m.recordedAt);
    _emit();
  }

  @override
  Future<void> deleteMetric(String metricId) async {
    _metrics.removeWhere((BodyMetric metric) => metric.id == metricId);
    _emit();
  }

  @override
  Stream<List<BodyMetric>> watchMetrics({MetricDateRange? range}) {
    if (range == null) {
      return _controller.stream;
    }
    return _controller.stream.map(
      (List<BodyMetric> metrics) => metrics
          .where(
            (BodyMetric metric) =>
                !metric.recordedAt.isBefore(range.start) &&
                !metric.recordedAt.isAfter(range.end),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<BodyMetric?> latestMetric() async {
    if (_metrics.isEmpty) {
      return null;
    }
    return _metrics.last;
  }

  @override
  Future<void> saveMetabolicProfile(MetabolicProfile profile) async {
    _profile = profile;
  }

  @override
  Future<MetabolicProfile?> loadMetabolicProfile() async {
    return _profile;
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List<BodyMetric>.unmodifiable(_metrics));
    }
  }
}
