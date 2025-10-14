// Analytics domain entities for lifting performance insights.
//
// These models remain framework-agnostic so they can be consumed by the
// application layer, persisted, or exposed to the UI as needed.

/// Represents a calculated one-repetition maximum (1RM) using different
/// estimation formulas.
class OneRepMaxEstimate {
  const OneRepMaxEstimate({required this.epley, required this.brzycki})
    : average = (epley + brzycki) / 2;

  /// Result of the Epley formula.
  final double epley;

  /// Result of the Brzycki formula.
  final double brzycki;

  /// Average between Epley and Brzycki estimations.
  final double average;

  OneRepMaxEstimate copyWith({double? epley, double? brzycki}) {
    final double nextEpley = epley ?? this.epley;
    final double nextBrzycki = brzycki ?? this.brzycki;
    return OneRepMaxEstimate(epley: nextEpley, brzycki: nextBrzycki);
  }
}

/// Personal record for a specific exercise (best set recorded).
class PersonalRecord {
  const PersonalRecord({
    required this.exerciseId,
    required this.oneRepMax,
    required this.bestWeight,
    required this.repetitions,
    required this.achievedAt,
    required this.sessionId,
    this.exerciseName,
    this.setNumber,
  });

  final String exerciseId;
  final String? exerciseName;
  final double oneRepMax;
  final double bestWeight;
  final int repetitions;
  final DateTime achievedAt;
  final String sessionId;
  final int? setNumber;

  PersonalRecord copyWith({
    String? exerciseId,
    String? exerciseName,
    double? oneRepMax,
    double? bestWeight,
    int? repetitions,
    DateTime? achievedAt,
    String? sessionId,
    int? setNumber,
  }) {
    return PersonalRecord(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      oneRepMax: oneRepMax ?? this.oneRepMax,
      bestWeight: bestWeight ?? this.bestWeight,
      repetitions: repetitions ?? this.repetitions,
      achievedAt: achievedAt ?? this.achievedAt,
      sessionId: sessionId ?? this.sessionId,
      setNumber: setNumber ?? this.setNumber,
    );
  }
}

/// Aggregated statistics for workouts across a given period.
class WorkoutStats {
  const WorkoutStats({
    required this.totalVolume,
    required this.totalSets,
    required this.totalSessions,
    required this.averageVolumePerSession,
  });

  final double totalVolume;
  final int totalSets;
  final int totalSessions;
  final double averageVolumePerSession;
}

/// Volume breakdown for a particular muscle group.
class MuscleGroupStat {
  const MuscleGroupStat({
    required this.group,
    required this.volume,
    required this.percentage,
  });

  final String group;
  final double volume;
  final double percentage;
}

/// Individual data point representing progress for an exercise.
class ExerciseProgressPoint {
  const ExerciseProgressPoint({
    required this.date,
    required this.totalVolume,
    required this.totalSets,
    this.estimatedOneRepMax,
  });

  final DateTime date;
  final double totalVolume;
  final int totalSets;
  final double? estimatedOneRepMax;
}

/// Progression summary for a specific exercise.
class ExerciseProgress {
  const ExerciseProgress({
    required this.exerciseId,
    required this.points,
    this.personalRecord,
  });

  final String exerciseId;
  final List<ExerciseProgressPoint> points;
  final PersonalRecord? personalRecord;
}

/// Consistency metrics summarising adherence to a training schedule.
class ConsistencyMetrics {
  const ConsistencyMetrics({
    required this.percentage,
    required this.activeDays,
    required this.totalDays,
    required this.currentStreak,
    required this.longestStreak,
  });

  final double percentage;
  final int activeDays;
  final int totalDays;
  final int currentStreak;
  final int longestStreak;
}
