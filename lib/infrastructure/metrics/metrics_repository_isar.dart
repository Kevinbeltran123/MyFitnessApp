import 'package:isar/isar.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/infrastructure/metrics/metrics_model.dart';

/// Isar implementation of MetricsRepository
class MetricsRepositoryIsar implements MetricsRepository {
  MetricsRepositoryIsar(this._isar);

  final Isar _isar;

  @override
  Future<void> upsertMetric(BodyMetric metric) async {
    final model = BodyMetricModel.fromDomain(metric);
    await _isar.writeTxn(() async {
      await _isar.bodyMetricModels.put(model);
    });
  }

  @override
  Future<void> deleteMetric(String metricId) async {
    await _isar.writeTxn(() async {
      final model = await _isar.bodyMetricModels
          .filter()
          .metricIdEqualTo(metricId)
          .findFirst();
      if (model != null) {
        await _isar.bodyMetricModels.delete(model.id);
      }
    });
  }

  @override
  Stream<List<BodyMetric>> watchMetrics({MetricDateRange? range}) {
    if (range != null) {
      return _isar.bodyMetricModels
          .filter()
          .recordedAtGreaterThan(range.start, include: true)
          .recordedAtLessThan(range.end, include: true)
          .sortByRecordedAtDesc()
          .watch(fireImmediately: true)
          .map((models) => models.map((m) => m.toDomain()).toList());
    }

    return _isar.bodyMetricModels
        .where()
        .sortByRecordedAtDesc()
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Future<BodyMetric?> latestMetric() async {
    final model =
        await _isar.bodyMetricModels.where().sortByRecordedAtDesc().findFirst();
    return model?.toDomain();
  }

  @override
  Future<void> saveMetabolicProfile(MetabolicProfile profile) async {
    final model = MetabolicProfileModel.fromDomain(profile);
    await _isar.writeTxn(() async {
      await _isar.metabolicProfileModels.put(model);
    });
  }

  @override
  Future<MetabolicProfile?> loadMetabolicProfile() async {
    final model = await _isar.metabolicProfileModels
        .where()
        .sortByUpdatedAtDesc()
        .findFirst();
    return model?.toDomain();
  }
}
