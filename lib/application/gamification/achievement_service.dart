import 'dart:math';

import 'package:collection/collection.dart';
import 'package:my_fitness_tracker/application/analytics/personal_record_service.dart';
import 'package:my_fitness_tracker/application/gamification/streak_tracker.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_definitions.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';

class AchievementService {
  AchievementService({
    required RoutineRepository routineRepository,
    required SessionRepository sessionRepository,
    required MetricsRepository metricsRepository,
    required PersonalRecordService personalRecordService,
    required StreakTracker streakTracker,
    AchievementCatalog? catalog,
  })  : _routineRepository = routineRepository,
        _sessionRepository = sessionRepository,
        _metricsRepository = metricsRepository,
        _personalRecordService = personalRecordService,
        _streakTracker = streakTracker,
        _catalog = catalog ?? kAchievementCatalog;

  final RoutineRepository _routineRepository;
  final SessionRepository _sessionRepository;
  final MetricsRepository _metricsRepository;
  final PersonalRecordService _personalRecordService;
  final StreakTracker _streakTracker;
  final AchievementCatalog _catalog;

  Future<List<Achievement>> evaluateAchievements({DateTime? anchor}) async {
    final List<RoutineSession> sessions =
        await _sessionRepository.getAllSessions();
    final List<Routine> routines = await _loadRoutines();
    final List<BodyMetric> metrics = await _loadMetrics();
    final List<PersonalRecord> personalRecords =
        await _personalRecordService.loadPersonalRecords();
    final StreakSnapshot streakSnapshot =
        await _streakTracker.buildSnapshot(anchor: anchor);

    final double totalVolume = _calculateTotalVolume(sessions);
    final int totalSessions = sessions.length;
    final _MetricProgress metricProgress = _calculateMetricProgress(metrics);

    final Map<String, double> progressMap = <String, double>{
      'achievement_first_routine': routines.isNotEmpty ? 1 : 0,
      'achievement_consistent_week': streakSnapshot.currentStreak.toDouble(),
      'achievement_warrior': streakSnapshot.currentStreak.toDouble(),
      'achievement_lifter': totalVolume,
      'achievement_titan': totalVolume,
      'achievement_dedicated': totalSessions.toDouble(),
      'achievement_centurion': totalSessions.toDouble(),
      'achievement_transformation': metricProgress.weightLoss,
      'achievement_gain': metricProgress.muscleGain,
      'achievement_record': personalRecords.isNotEmpty ? 1 : 0,
    };

    return _catalog
        .map((definition) {
          final double value = progressMap[definition.id] ?? 0;
          return definition.createInstance(currentValue: value);
        })
        .toList(growable: false);
  }

  Future<List<Routine>> _loadRoutines() {
    return _routineRepository.watchAll(includeArchived: true).first;
  }

  Future<List<BodyMetric>> _loadMetrics() {
    return _metricsRepository.watchMetrics().first;
  }

  double _calculateTotalVolume(List<RoutineSession> sessions) {
    return sessions.fold<double>(
      0,
      (total, session) => total + session.exerciseLogs.fold<double>(
        0,
        (subTotal, log) => subTotal + log.setLogs.fold<double>(
              0,
              (setTotal, set) => setTotal + max(0, set.weight) * set.repetitions,
            ),
      ),
    );
  }
}

class _MetricProgress {
  const _MetricProgress({required this.weightLoss, required this.muscleGain});

  final double weightLoss;
  final double muscleGain;
}

_MetricProgress _calculateMetricProgress(List<BodyMetric> metrics) {
  if (metrics.length < 2) {
    return const _MetricProgress(weightLoss: 0, muscleGain: 0);
  }

  final BodyMetric latest = metrics.first;
  final BodyMetric oldest = metrics.last;

  final double weightLoss = max(0, oldest.weightKg - latest.weightKg);

  final BodyMetric? latestMuscle =
      metrics.firstWhereOrNull((metric) => metric.muscleMassKg != null);
  final BodyMetric? oldestMuscle =
      metrics.lastWhereOrNull((metric) => metric.muscleMassKg != null);

  double muscleGain = 0;
  if (latestMuscle != null && oldestMuscle != null) {
    muscleGain = max(
      0,
      (latestMuscle.muscleMassKg ?? 0) - (oldestMuscle.muscleMassKg ?? 0),
    );
  }

  return _MetricProgress(weightLoss: weightLoss, muscleGain: muscleGain);
}
