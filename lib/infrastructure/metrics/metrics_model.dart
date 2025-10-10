import 'package:isar/isar.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';

part 'metrics_model.g.dart';

/// Isar model for body metrics
@Collection()
class BodyMetricModel {
  BodyMetricModel();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String metricId;

  @Index()
  late DateTime recordedAt;

  late double weightKg;
  double? bodyFatPercentage;
  double? muscleMassKg;
  String? notes;

  /// Store measurements as JSON-like map
  /// Keys are anatomical references (e.g., "cintura", "pecho", "muslo")
  List<String> measurementKeys = <String>[];
  List<double> measurementValues = <double>[];

  BodyMetric toDomain() {
    final measurements = <String, double>{};
    for (int i = 0; i < measurementKeys.length; i++) {
      measurements[measurementKeys[i]] = measurementValues[i];
    }

    return BodyMetric(
      id: metricId,
      recordedAt: recordedAt,
      weightKg: weightKg,
      bodyFatPercentage: bodyFatPercentage,
      muscleMassKg: muscleMassKg,
      notes: notes,
      measurements: measurements,
    );
  }

  static BodyMetricModel fromDomain(BodyMetric metric) {
    final model = BodyMetricModel()
      ..metricId = metric.id
      ..recordedAt = metric.recordedAt
      ..weightKg = metric.weightKg
      ..bodyFatPercentage = metric.bodyFatPercentage
      ..muscleMassKg = metric.muscleMassKg
      ..notes = metric.notes
      ..measurementKeys = metric.measurements.keys.toList()
      ..measurementValues = metric.measurements.values.toList();
    return model;
  }

  /// Calculated BMI (helper method, not persisted)
  double? calculateBMI(double? heightCm) {
    if (heightCm == null || heightCm <= 0) return null;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
}

/// Isar model for metabolic profile
@Collection()
class MetabolicProfileModel {
  MetabolicProfileModel();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String profileId;

  late DateTime updatedAt;
  late double heightCm;
  late double weightKg;
  late int age;

  @enumerated
  late BiologicalSex sex;

  double activityMultiplier = 1.2;

  MetabolicProfile toDomain() {
    return MetabolicProfile(
      id: profileId,
      updatedAt: updatedAt,
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      sex: sex,
      activityMultiplier: activityMultiplier,
    );
  }

  static MetabolicProfileModel fromDomain(MetabolicProfile profile) {
    final model = MetabolicProfileModel()
      ..profileId = profile.id
      ..updatedAt = profile.updatedAt
      ..heightCm = profile.heightCm
      ..weightKg = profile.weightKg
      ..age = profile.age
      ..sex = profile.sex
      ..activityMultiplier = profile.activityMultiplier;
    return model;
  }
}
