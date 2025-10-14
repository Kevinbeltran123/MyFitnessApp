// Domain primitives for tracking corporal metrics and metabolic profile.
// These models are used by the application layer and remain persistence and
// framework agnostic.

enum BiologicalSex { male, female, other }

class BodyMetric {
  const BodyMetric({
    required this.id,
    required this.recordedAt,
    required this.weightKg,
    this.bodyFatPercentage,
    this.muscleMassKg,
    this.notes,
    this.measurements = const <String, double>{},
  });

  final String id;
  final DateTime recordedAt;
  final double weightKg;
  final double? bodyFatPercentage;
  final double? muscleMassKg;
  final String? notes;

  // Circumference measurements keyed by anatomical reference (p.ej. "cintura").
  final Map<String, double> measurements;

  BodyMetric copyWith({
    String? id,
    DateTime? recordedAt,
    double? weightKg,
    double? bodyFatPercentage,
    double? muscleMassKg,
    String? notes,
    Map<String, double>? measurements,
  }) {
    return BodyMetric(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMassKg: muscleMassKg ?? this.muscleMassKg,
      notes: notes ?? this.notes,
      measurements: measurements ?? this.measurements,
    );
  }
}

class MetabolicProfile {
  const MetabolicProfile({
    required this.id,
    required this.updatedAt,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.sex,
    this.activityMultiplier = 1.2,
    this.profileImagePath,
  });

  final String id;
  final DateTime updatedAt;
  final double heightCm;
  final double weightKg;
  final int age;
  final BiologicalSex sex;
  final double activityMultiplier;
  final String? profileImagePath;

  // Basal metabolic rate calculated using Mifflin-St Jeor formula.
  double get basalMetabolicRate {
    final double base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    switch (sex) {
      case BiologicalSex.male:
        return base + 5;
      case BiologicalSex.female:
        return base - 161;
      case BiologicalSex.other:
        return base - 78;
    }
  }

  double get maintenanceCalories => basalMetabolicRate * activityMultiplier;

  MetabolicProfile copyWith({
    double? heightCm,
    double? weightKg,
    int? age,
    BiologicalSex? sex,
    double? activityMultiplier,
    DateTime? updatedAt,
    String? profileImagePath,
    bool clearProfileImage = false,
  }) {
    return MetabolicProfile(
      id: id,
      updatedAt: updatedAt ?? DateTime.now(),
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      activityMultiplier: activityMultiplier ?? this.activityMultiplier,
      profileImagePath: clearProfileImage
          ? null
          : (profileImagePath ?? this.profileImagePath),
    );
  }
}

class MetricDateRange {
  const MetricDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

abstract class MetricsRepository {
  Future<void> upsertMetric(BodyMetric metric);

  Future<void> deleteMetric(String metricId);

  Stream<List<BodyMetric>> watchMetrics({MetricDateRange? range});

  Future<BodyMetric?> latestMetric();

  Future<void> saveMetabolicProfile(MetabolicProfile profile);

  Future<MetabolicProfile?> loadMetabolicProfile();
}
