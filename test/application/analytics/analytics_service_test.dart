import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/analytics/analytics_service.dart';
import 'package:my_fitness_tracker/application/analytics/one_rep_max_calculator.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';

import '../../support/fake_session_repository.dart';

void main() {
  group('AnalyticsService', () {
    late FakeSessionRepository repository;
    late AnalyticsService service;

    setUp(() {
      repository = FakeSessionRepository();
      service = AnalyticsService(
        sessionRepository: repository,
        calculator: const OneRepMaxCalculator(),
      );
    });

    test('calculateWeeklyVolume sums volume for the week', () async {
      repository.setSessions([
        _session(
          id: 's1',
          completedAt: DateTime(2025, 10, 13, 18),
          logs: {
            'bench-press': [_setLog(setNumber: 1, weight: 80, reps: 5)],
          },
        ),
        _session(
          id: 's2',
          completedAt: DateTime(2025, 10, 15, 19),
          logs: {
            'squat': [_setLog(setNumber: 1, weight: 100, reps: 5)],
          },
        ),
      ]);

      final volume = await service.calculateWeeklyVolume(
        DateTime(2025, 10, 14),
      );
      expect(volume, closeTo(80 * 5 + 100 * 5, 0.001));
    });

    test('calculateMonthlyVolume aggregates sessions across month', () async {
      repository.setSessions([
        _session(
          id: 's1',
          completedAt: DateTime(2025, 9, 2),
          logs: {
            'deadlift': [_setLog(setNumber: 1, weight: 140, reps: 3)],
          },
        ),
        _session(
          id: 's2',
          completedAt: DateTime(2025, 9, 20),
          logs: {
            'push-up': [_setLog(setNumber: 1, weight: 0, reps: 20)],
          },
        ),
      ]);

      final volume = await service.calculateMonthlyVolume(
        DateTime(2025, 9, 10),
      );
      expect(volume, closeTo(140 * 3, 0.001));
    });

    test('getMuscleGroupStats groups exercises', () async {
      repository.setSessions([
        _session(
          id: 's1',
          completedAt: DateTime(2025, 8, 10),
          logs: {
            'bench-press': [_setLog(setNumber: 1, weight: 90, reps: 5)],
            'deadlift': [_setLog(setNumber: 1, weight: 150, reps: 3)],
          },
        ),
      ]);

      final range = MetricDateRange(
        start: DateTime(2025, 8, 1),
        end: DateTime(2025, 8, 31, 23, 59, 59),
      );

      final stats = await service.getMuscleGroupStats(range);
      final Map<String, MuscleGroupStat> map = {
        for (final stat in stats) stat.group: stat,
      };
      expect(map['Pecho']?.volume, closeTo(90 * 5, 0.001));
      expect(map['Espalda']?.volume, closeTo(150 * 3, 0.001));
      expect(
        (map['Pecho']!.percentage + map['Espalda']!.percentage),
        closeTo(100, 0.001),
      );
    });

    test('calculateTrainingFrequency counts sessions in range', () async {
      repository.setSessions([
        _session(id: 's1', completedAt: DateTime(2025, 7, 1, 12)),
        _session(id: 's2', completedAt: DateTime(2025, 7, 3, 8)),
        _session(id: 's3', completedAt: DateTime(2025, 7, 10, 18)),
      ]);

      final range = MetricDateRange(
        start: DateTime(2025, 7, 1),
        end: DateTime(2025, 7, 7),
      );

      final frequency = await service.calculateTrainingFrequency(range);
      expect(frequency, 2);
    });

    test('calculateConsistency returns active-day percentage', () async {
      repository.setSessions([
        _session(id: 's1', completedAt: DateTime(2025, 6, 1, 9)),
        _session(id: 's2', completedAt: DateTime(2025, 6, 3, 12)),
        _session(id: 's3', completedAt: DateTime(2025, 6, 3, 20)),
      ]);

      final range = MetricDateRange(
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 4),
      );

      final consistency = await service.calculateConsistency(range);
      // Two active days (1st and 3rd) across four days.
      expect(consistency, closeTo(50, 0.01));
    });

    test('getConsistencyMetrics returns streak details', () async {
      repository.setSessions([
        _session(id: 's1', completedAt: DateTime(2025, 6, 1, 9)),
        _session(id: 's2', completedAt: DateTime(2025, 6, 2, 12)),
        _session(id: 's3', completedAt: DateTime(2025, 6, 4, 18)),
      ]);

      final range = MetricDateRange(
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 5),
      );

      final metrics = await service.getConsistencyMetrics(range);
      expect(metrics.activeDays, 3);
      expect(metrics.longestStreak, 2);
    });

    test('buildWorkoutStats aggregates totals', () async {
      repository.setSessions([
        _session(
          id: 's1',
          completedAt: DateTime(2025, 5, 1, 9),
          logs: {
            'bench-press': [_setLog(setNumber: 1, weight: 100, reps: 5)],
          },
        ),
        _session(
          id: 's2',
          completedAt: DateTime(2025, 5, 2, 9),
          logs: {
            'squat': [_setLog(setNumber: 1, weight: 140, reps: 5)],
          },
        ),
      ]);

      final stats = await service.buildWorkoutStats(
        MetricDateRange(start: DateTime(2025, 5, 1), end: DateTime(2025, 5, 7)),
      );

      expect(stats.totalSessions, 2);
      expect(stats.totalSets, 2);
      expect(stats.totalVolume, closeTo(100 * 5 + 140 * 5, 0.001));
    });

    test('getExerciseProgress returns timeline and PR', () async {
      repository.setSessions([
        _session(
          id: 's1',
          completedAt: DateTime(2025, 4, 1, 10),
          logs: {
            'bench-press': [_setLog(setNumber: 1, weight: 90, reps: 5)],
          },
        ),
        _session(
          id: 's2',
          completedAt: DateTime(2025, 4, 5, 10),
          logs: {
            'bench-press': [_setLog(setNumber: 1, weight: 95, reps: 5)],
          },
        ),
      ]);

      final progress = await service.getExerciseProgress(
        'bench-press',
        MetricDateRange(
          start: DateTime(2025, 4, 1),
          end: DateTime(2025, 4, 30),
        ),
      );

      expect(progress.points, hasLength(2));
      expect(progress.personalRecord?.bestWeight, 95);
    });

    test('estimateOneRepMax delegates to calculator', () {
      final estimate = service.estimateOneRepMax(weight: 100, repetitions: 3);
      expect(estimate, isNotNull);
      expect(estimate!.average, greaterThan(100));
    });
  });
}

RoutineSession _session({
  required String id,
  required DateTime completedAt,
  Map<String, List<SetLog>> logs = const <String, List<SetLog>>{},
}) {
  final List<RoutineExerciseLog> exerciseLogs = logs.entries
      .map(
        (entry) =>
            RoutineExerciseLog(exerciseId: entry.key, setLogs: entry.value),
      )
      .toList();
  return RoutineSession(
    id: id,
    routineId: 'routine-${completedAt.microsecondsSinceEpoch}',
    startedAt: completedAt.subtract(const Duration(hours: 1)),
    completedAt: completedAt,
    exerciseLogs: exerciseLogs,
    notes: null,
  );
}

SetLog _setLog({
  required int setNumber,
  required double weight,
  required int reps,
}) {
  return SetLog(
    setNumber: setNumber,
    repetitions: reps,
    weight: weight,
    restTaken: const Duration(seconds: 90),
  );
}
