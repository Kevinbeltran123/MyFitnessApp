import 'package:collection/collection.dart';
import 'package:my_fitness_tracker/application/analytics/one_rep_max_calculator.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';

/// Provides aggregate workout analytics derived from logged routine sessions.
class AnalyticsService {
  AnalyticsService({
    required SessionRepository sessionRepository,
    OneRepMaxCalculator? calculator,
    Map<String, String>? exerciseMuscleGroupMap,
  }) : _sessionRepository = sessionRepository,
       _calculator = calculator ?? const OneRepMaxCalculator(),
       _exerciseMuscleGroupMap = Map<String, String>.unmodifiable(
         Map<String, String>.from(
           exerciseMuscleGroupMap ?? _defaultExerciseMuscleGroupMap,
         ),
       );

  final SessionRepository _sessionRepository;
  final OneRepMaxCalculator _calculator;
  final Map<String, String> _exerciseMuscleGroupMap;

  /// Calculates total lifted volume (kg * reps) for the week that contains
  /// [date]. Weeks start on Monday.
  Future<double> calculateWeeklyVolume(DateTime date) async {
    final DateTime start = _startOfWeek(date);
    final DateTime end = _endOfDay(start.add(const Duration(days: 6)));
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: start, endDate: end);
    return _totalVolume(sessions);
  }

  /// Calculates total lifted volume for the month identified by [date].
  Future<double> calculateMonthlyVolume(DateTime date) async {
    final DateTime start = _startOfDay(DateTime(date.year, date.month, 1));
    final DateTime end = _endOfDay(DateTime(date.year, date.month + 1, 0));
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: start, endDate: end);
    return _totalVolume(sessions);
  }

  /// Builds a time series of lifted volume for chart visualisations.
  ///
  /// By default returns the last 12 periods ending on [anchor] (inclusive).
  Future<VolumeSeries> buildVolumeSeries({
    required VolumeAggregation aggregation,
    DateTime? anchor,
    int periods = 12,
  }) async {
    assert(periods > 0, 'periods must be greater than zero');
    final DateTime reference = anchor ?? DateTime.now();

    late final DateTime seriesStart;
    late final DateTime seriesEnd;

    switch (aggregation) {
      case VolumeAggregation.weekly:
        final DateTime currentWeekStart = _startOfWeek(reference);
        seriesEnd = _endOfDay(currentWeekStart.add(const Duration(days: 6)));
        seriesStart = currentWeekStart.subtract(
          Duration(days: 7 * (periods - 1)),
        );
        break;
      case VolumeAggregation.monthly:
        final DateTime currentMonthStart = _startOfMonth(reference);
        seriesEnd = _endOfMonth(currentMonthStart);
        seriesStart = _startOfMonth(
          DateTime(
            currentMonthStart.year,
            currentMonthStart.month - (periods - 1),
            1,
          ),
        );
        break;
    }

    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: seriesStart, endDate: seriesEnd);

    final Map<DateTime, double> bucketVolumes = <DateTime, double>{};
    for (final RoutineSession session in sessions) {
      final double sessionVolume = _sessionVolume(session);
      if (sessionVolume == 0) {
        continue;
      }

      final DateTime bucketStart = aggregation == VolumeAggregation.weekly
          ? _startOfWeek(session.completedAt)
          : _startOfMonth(session.completedAt);

      bucketVolumes[bucketStart] =
          (bucketVolumes[bucketStart] ?? 0) + sessionVolume;
    }

    final List<VolumeDataPoint> points = <VolumeDataPoint>[];
    for (int index = 0; index < periods; index += 1) {
      switch (aggregation) {
        case VolumeAggregation.weekly:
          final DateTime start = seriesStart.add(Duration(days: 7 * index));
          final DateTime end = _endOfDay(start.add(const Duration(days: 6)));
          final double volume = bucketVolumes[start] ?? 0;
          points.add(VolumeDataPoint(start: start, end: end, volume: volume));
          break;
        case VolumeAggregation.monthly:
          final DateTime start = _startOfMonth(
            DateTime(seriesStart.year, seriesStart.month + index, 1),
          );
          final DateTime end = _endOfMonth(start);
          final double volume = bucketVolumes[start] ?? 0;
          points.add(VolumeDataPoint(start: start, end: end, volume: volume));
          break;
      }
    }

    final double total = points.fold<double>(0, (
      double acc,
      VolumeDataPoint p,
    ) {
      return acc + p.volume;
    });
    final double max = points.fold<double>(0, (
      double current,
      VolumeDataPoint p,
    ) {
      return p.volume > current ? p.volume : current;
    });

    return VolumeSeries(
      aggregation: aggregation,
      points: List<VolumeDataPoint>.unmodifiable(points),
      totalVolume: total,
      maxVolume: max,
    );
  }

  /// Builds heatmap-ready data for the last [days] (default 90).
  Future<TrainingHeatmapData> buildTrainingHeatmap({
    DateTime? anchor,
    int days = 90,
  }) async {
    assert(days > 0, 'days must be greater than zero');
    final DateTime reference = anchor ?? DateTime.now();
    final DateTime end = _endOfDay(reference);
    final DateTime start = _startOfDay(end.subtract(Duration(days: days - 1)));

    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: start, endDate: end);

    final Map<DateTime, _DailyAggregate> aggregates =
        <DateTime, _DailyAggregate>{};
    for (final RoutineSession session in sessions) {
      final DateTime day = _startOfDay(session.completedAt);
      final _DailyAggregate aggregate = aggregates.putIfAbsent(
        day,
        () => _DailyAggregate.zero(),
      );
      final double sessionVolume = _sessionVolume(session);
      aggregates[day] = aggregate.add(sessionVolume);
    }

    final List<DailyActivityPoint> points = <DailyActivityPoint>[];
    DateTime cursor = start;
    while (!cursor.isAfter(end)) {
      final _DailyAggregate aggregate =
          aggregates[cursor] ?? _DailyAggregate.zero();
      points.add(
        DailyActivityPoint(
          date: cursor,
          sessionCount: aggregate.count,
          totalVolume: aggregate.volume,
        ),
      );
      cursor = cursor.add(const Duration(days: 1));
    }

    final List<DateTime> activeDays =
        aggregates.entries
            .where((entry) => entry.value.count > 0)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final _StreakStats streaks = _calculateStreaks(activeDays, end);

    final DateTime monthStart = _startOfMonth(reference);
    final DateTime monthEnd = _endOfMonth(monthStart);
    final Iterable<DailyActivityPoint> monthPoints = points.where(
      (point) =>
          !point.date.isBefore(monthStart) && !point.date.isAfter(monthEnd),
    );

    DailyActivityPoint? mostProductive;
    for (final DailyActivityPoint point in monthPoints) {
      if (point.totalVolume <= 0 && point.sessionCount == 0) {
        continue;
      }
      if (mostProductive == null) {
        mostProductive = point;
        continue;
      }
      final bool higherVolume = point.totalVolume > mostProductive.totalVolume;
      final bool equalVolume =
          (point.totalVolume - mostProductive.totalVolume).abs() < 1e-6;
      final bool higherSessions =
          point.sessionCount > mostProductive.sessionCount;
      if (higherVolume || (equalVolume && higherSessions)) {
        mostProductive = point;
      }
    }

    return TrainingHeatmapData(
      points: List<DailyActivityPoint>.unmodifiable(points),
      currentStreak: streaks.current,
      longestStreak: streaks.longest,
      mostProductiveDay: mostProductive,
      range: MetricDateRange(start: start, end: end),
    );
  }

  /// Breaks down volume lifted per muscle group within the given [range].
  Future<List<MuscleGroupStat>> getMuscleGroupStats(
    MetricDateRange range,
  ) async {
    final DateTime start = _startOfDay(range.start);
    final DateTime end = _endOfDay(range.end);
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: start, endDate: end);

    final Map<String, double> totals = <String, double>{};
    for (final RoutineSession session in sessions) {
      for (final RoutineExerciseLog log in session.exerciseLogs) {
        final String group =
            _exerciseMuscleGroupMap[log.exerciseId] ?? 'General';
        final double exerciseVolume = log.setLogs.fold<double>(
          0,
          (double acc, SetLog set) => acc + _setVolume(set),
        );
        totals[group] = (totals[group] ?? 0) + exerciseVolume;
      }
    }

    final double totalVolume = totals.values.fold<double>(0, (a, b) => a + b);
    return totals.entries
        .map(
          (entry) => MuscleGroupStat(
            group: entry.key,
            volume: entry.value,
            percentage: totalVolume == 0
                ? 0
                : (entry.value / totalVolume) * 100,
          ),
        )
        .toList(growable: false);
  }

  /// Returns the total number of sessions completed within [range].
  Future<int> calculateTrainingFrequency(MetricDateRange range) async {
    final DateTime start = _startOfDay(range.start);
    final DateTime end = _endOfDay(range.end);
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: start, endDate: end);
    return sessions.length;
  }

  /// Calculates the percentage of active days (days with at least one session)
  /// in the provided [range].
  Future<double> calculateConsistency(MetricDateRange range) async {
    final ConsistencyMetrics metrics = await getConsistencyMetrics(range);
    return metrics.percentage;
  }

  /// Builds a detailed workout summary for the provided [range].
  Future<WorkoutStats> buildWorkoutStats(MetricDateRange range) async {
    final DateTime start = _startOfDay(range.start);
    final DateTime end = _endOfDay(range.end);
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: start, endDate: end);
    final double volume = _totalVolume(sessions);
    final int totalSets = sessions.fold<int>(
      0,
      (int acc, RoutineSession session) =>
          acc +
          session.exerciseLogs.fold<int>(
            0,
            (int subtotal, RoutineExerciseLog log) =>
                subtotal + log.setLogs.length,
          ),
    );
    final int sessionCount = sessions.length;
    final double averageVolume = sessionCount == 0 ? 0 : volume / sessionCount;
    return WorkoutStats(
      totalVolume: volume,
      totalSets: totalSets,
      totalSessions: sessionCount,
      averageVolumePerSession: averageVolume,
    );
  }

  /// Generates muscle-group statistics with percentages for the [range].
  Future<List<MuscleGroupStat>> muscleGroupStats(MetricDateRange range) =>
      getMuscleGroupStats(range);

  /// Returns consistency metrics (active days, streaks, etc.) for [range].
  Future<ConsistencyMetrics> getConsistencyMetrics(
    MetricDateRange range,
  ) async {
    final DateTime start = _startOfDay(range.start);
    final DateTime end = _endOfDay(range.end);
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: start, endDate: end);
    if (sessions.isEmpty) {
      final int totalDays = end.difference(start).inDays.abs() + 1;
      return ConsistencyMetrics(
        percentage: 0,
        activeDays: 0,
        totalDays: totalDays,
        currentStreak: 0,
        longestStreak: 0,
      );
    }

    final List<DateTime> days =
        sessions
            .map((RoutineSession session) => _startOfDay(session.completedAt))
            .toSet()
            .toList()
          ..sort();
    final int activeDays = days.length;
    final int totalDays = end.difference(start).inDays.abs() + 1;
    final _StreakStats streaks = _calculateStreaks(days, end);
    final double percentage = totalDays == 0
        ? 0
        : (activeDays / totalDays) * 100;
    return ConsistencyMetrics(
      percentage: percentage,
      activeDays: activeDays,
      totalDays: totalDays,
      currentStreak: streaks.current,
      longestStreak: streaks.longest,
    );
  }

  /// Builds an exercise progress timeline for the given [exerciseId].
  Future<ExerciseProgress> getExerciseProgress(
    String exerciseId,
    MetricDateRange range,
  ) async {
    final DateTime start = _startOfDay(range.start);
    final DateTime end = _endOfDay(range.end);
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions(startDate: start, endDate: end);

    final List<ExerciseProgressPoint> points = <ExerciseProgressPoint>[];
    PersonalRecord? bestRecord;

    for (final RoutineSession session in sessions) {
      final RoutineExerciseLog? log = session.exerciseLogs.firstWhereOrNull(
        (RoutineExerciseLog element) => element.exerciseId == exerciseId,
      );
      if (log == null || log.setLogs.isEmpty) {
        continue;
      }
      final double volume = log.setLogs.fold<double>(
        0,
        (double acc, SetLog set) => acc + _setVolume(set),
      );
      final int sets = log.setLogs.length;

      final SetLog topSet = log.setLogs.reduce(
        (SetLog a, SetLog b) => (a.weight > b.weight) ? a : b,
      );
      final OneRepMaxEstimate? estimate = _calculator.estimate(
        weight: topSet.weight,
        repetitions: topSet.repetitions,
      );

      if (estimate != null) {
        final PersonalRecord candidate = PersonalRecord(
          exerciseId: exerciseId,
          oneRepMax: estimate.average,
          bestWeight: topSet.weight,
          repetitions: topSet.repetitions,
          achievedAt: session.completedAt,
          sessionId: session.id,
        );
        final double previousBest =
            bestRecord?.oneRepMax ?? double.negativeInfinity;
        if (candidate.oneRepMax > previousBest + 1e-6) {
          bestRecord = candidate;
        }
      }

      points.add(
        ExerciseProgressPoint(
          date: session.completedAt,
          totalVolume: volume,
          totalSets: sets,
          estimatedOneRepMax: estimate?.average,
        ),
      );
    }

    points.sort((a, b) => a.date.compareTo(b.date));

    return ExerciseProgress(
      exerciseId: exerciseId,
      points: points,
      personalRecord: bestRecord,
    );
  }

  /// Estimates the one-repetition maximum using common strength formulas.
  OneRepMaxEstimate? estimateOneRepMax({
    required double weight,
    required int repetitions,
  }) {
    return _calculator.estimate(weight: weight, repetitions: repetitions);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  static DateTime _startOfWeek(DateTime date) {
    final DateTime normalized = _startOfDay(date);
    final int daysToSubtract = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: daysToSubtract));
  }

  double _totalVolume(List<RoutineSession> sessions) {
    return sessions.fold<double>(0, (double acc, RoutineSession session) {
      return acc + _sessionVolume(session);
    });
  }

  double _sessionVolume(RoutineSession session) {
    return session.exerciseLogs.fold<double>(
      0,
      (double subtotal, RoutineExerciseLog log) =>
          subtotal +
          log.setLogs.fold<double>(
            0,
            (double setTotal, SetLog set) => setTotal + _setVolume(set),
          ),
    );
  }

  double _setVolume(SetLog set) {
    final double weight = set.weight <= 0 ? 0 : set.weight;
    return weight * set.repetitions.toDouble();
  }

  static DateTime _startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime _endOfMonth(DateTime date) =>
      _endOfDay(DateTime(date.year, date.month + 1, 0));

  _StreakStats _calculateStreaks(List<DateTime> activeDays, DateTime rangeEnd) {
    if (activeDays.isEmpty) {
      return const _StreakStats(current: 0, longest: 0);
    }

    int longest = 1;
    int streak = 1;
    for (int i = 1; i < activeDays.length; i += 1) {
      final DateTime previous = activeDays[i - 1];
      final DateTime currentDay = activeDays[i];
      if (currentDay.difference(previous).inDays == 1) {
        streak += 1;
      } else {
        if (streak > longest) {
          longest = streak;
        }
        streak = 1;
      }
    }
    if (streak > longest) {
      longest = streak;
    }

    int current = 0;
    DateTime cursor = _startOfDay(rangeEnd);
    final Set<DateTime> activeSet = activeDays.toSet();
    while (activeSet.contains(cursor)) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return _StreakStats(current: current, longest: longest);
  }
}

const Map<String, String> _defaultExerciseMuscleGroupMap = <String, String>{
  'bench-press': 'Pecho',
  'push-up': 'Pecho',
  'deadlift': 'Espalda',
  'squat': 'Piernas',
  'pull-up': 'Espalda',
  'overhead-press': 'Hombros',
  'bicep-curl': 'Brazos',
  'tricep-dip': 'Brazos',
  'plank': 'Core',
};

class _StreakStats {
  const _StreakStats({required this.current, required this.longest});

  final int current;
  final int longest;
}

class _DailyAggregate {
  const _DailyAggregate({required this.count, required this.volume});

  factory _DailyAggregate.zero() => const _DailyAggregate(count: 0, volume: 0);

  final int count;
  final double volume;

  _DailyAggregate add(double sessionVolume) {
    return _DailyAggregate(count: count + 1, volume: volume + sessionVolume);
  }
}
