import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/analytics/analytics_service.dart';
import 'package:my_fitness_tracker/application/gamification/streak_tracker.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';
import 'package:my_fitness_tracker/presentation/achievements/achievements_providers.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart'
    as metrics;
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';

part 'models/home_dashboard_models.dart';

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardState>(
      HomeDashboardNotifier.new,
    );

class HomeDashboardNotifier extends AsyncNotifier<HomeDashboardState> {
  @override
  Future<HomeDashboardState> build() async {
    final DateTime now = DateTime.now();

    final AnalyticsService analyticsService = await ref.watch(
      analyticsServiceProvider.future,
    );
    final RoutineRepository routineRepository = await ref.watch(
      routineRepositoryProvider.future,
    );
    final SessionRepository sessionRepository = await ref.watch(
      sessionRepositoryProvider.future,
    );
    final MetricsRepository metricsRepository = await ref.watch(
      metrics.metricsRepositoryProvider.future,
    );
    final StreakSnapshot streakSnapshot = await ref.watch(
      currentStreakProvider.future,
    );

    final List<Routine> routines = await routineRepository
        .watchAll(includeArchived: false)
        .first;
    final List<RoutineSession> sessions = await sessionRepository
        .getAllSessions();
    final List<BodyMetric> metricList = await metricsRepository
        .watchMetrics()
        .first;
    final BodyMetric? latestMetric = metricList.isNotEmpty
        ? metricList.first
        : null;

    final AsyncValue<List<Achievement>> achievementsAsync = ref.watch(
      achievementsProvider,
    );
    final List<Achievement> achievements = List<Achievement>.from(
      achievementsAsync.valueOrNull ?? const <Achievement>[],
    );

    final double weeklyVolume = await analyticsService.calculateWeeklyVolume(
      now,
    );
    final MetricDateRange monthRange = _currentMonthRange(now);
    final int monthlySessions = await analyticsService
        .calculateTrainingFrequency(monthRange);

    final RoutineSummary? nextRoutine = _computeNextRoutine(
      now,
      routines,
      sessions,
    );
    final List<HomeCalendarDay> calendar = _buildWeeklyCalendar(
      now,
      routines,
      sessions,
    );
    final List<MetricSparkPoint> sparkline = _buildSparkline(metricList);
    final List<Achievement> recentAchievements = _recentUnlockedAchievements(
      achievements,
    );
    final List<HomeQuickStat> quickStats = _buildQuickStats(
      weeklyVolume: weeklyVolume,
      monthlySessions: monthlySessions,
      latestMetric: latestMetric,
    );

    final String greeting = _greetingFor(now);
    final String motivationalMessage = _motivationalMessage(
      now,
      streakSnapshot,
      nextRoutine,
    );

    return HomeDashboardState(
      generatedAt: now,
      greeting: greeting,
      motivationalMessage: motivationalMessage,
      streakSnapshot: streakSnapshot,
      nextRoutine: nextRoutine,
      quickStats: quickStats,
      sparkline: sparkline,
      calendar: calendar,
      recentAchievements: recentAchievements,
      latestMetric: latestMetric,
      weeklyVolume: weeklyVolume,
      monthlySessions: monthlySessions,
    );
  }

  static RoutineSummary? _computeNextRoutine(
    DateTime now,
    List<Routine> routines,
    List<RoutineSession> sessions,
  ) {
    if (routines.isEmpty) {
      return null;
    }
    final DateTime today = DateTime(now.year, now.month, now.day);
    RoutineSummary? closest;
    for (final Routine routine in routines) {
      if (routine.isArchived || routine.daysOfWeek.isEmpty) {
        continue;
      }
      final DateTime nextDate = _nextScheduledDate(today, routine);
      if (closest == null || nextDate.isBefore(closest.nextOccurrence)) {
        final RoutineSession? lastSession = sessions.firstWhereOrNull(
          (session) => session.routineId == routine.id,
        );
        closest = RoutineSummary(
          routineId: routine.id,
          name: routine.name,
          focus: routine.focus,
          nextOccurrence: nextDate,
          lastCompletedAt: lastSession?.completedAt,
        );
      }
    }
    return closest;
  }

  static List<HomeCalendarDay> _buildWeeklyCalendar(
    DateTime anchor,
    List<Routine> routines,
    List<RoutineSession> sessions,
  ) {
    final DateTime start = _startOfWeek(anchor);
    final Map<DateTime, List<Routine>> scheduledByDay = {};
    for (final Routine routine in routines) {
      if (routine.isArchived || routine.daysOfWeek.isEmpty) {
        continue;
      }
      for (final RoutineDay day in routine.daysOfWeek) {
        final DateTime occurrence = _nextOccurrenceOnWeek(start, day.weekday);
        final DateTime normalized = DateTime(
          occurrence.year,
          occurrence.month,
          occurrence.day,
        );
        scheduledByDay.putIfAbsent(normalized, () => <Routine>[]);
        scheduledByDay[normalized]!.add(routine);
      }
    }

    final Set<DateTime> completedDates = sessions
        .map(
          (session) => DateTime(
            session.completedAt.year,
            session.completedAt.month,
            session.completedAt.day,
          ),
        )
        .toSet();

    final List<HomeCalendarDay> days = <HomeCalendarDay>[];
    for (int i = 0; i < 7; i += 1) {
      final DateTime date = start.add(Duration(days: i));
      final DateTime normalized = DateTime(date.year, date.month, date.day);
      final List<Routine> scheduled = scheduledByDay[normalized] ?? const [];
      final bool completed = completedDates.contains(normalized);
      days.add(
        HomeCalendarDay(
          date: normalized,
          scheduledRoutines: scheduled
              .map(
                (routine) => RoutineSummary(
                  routineId: routine.id,
                  name: routine.name,
                  focus: routine.focus,
                  nextOccurrence: normalized,
                  lastCompletedAt: null,
                ),
              )
              .toList(growable: false),
          isCompleted: completed,
        ),
      );
    }
    return days;
  }

  static List<MetricSparkPoint> _buildSparkline(List<BodyMetric> metrics) {
    if (metrics.isEmpty) return const <MetricSparkPoint>[];
    final List<BodyMetric> sorted = List<BodyMetric>.from(metrics)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final int startIndex = sorted.length > 14 ? sorted.length - 14 : 0;
    final List<BodyMetric> recent = sorted.sublist(startIndex);
    return recent
        .map(
          (metric) =>
              MetricSparkPoint(date: metric.recordedAt, value: metric.weightKg),
        )
        .toList(growable: false);
  }

  static List<Achievement> _recentUnlockedAchievements(
    List<Achievement> achievements,
  ) {
    final List<Achievement> unlocked = achievements
        .where((achievement) => achievement.isUnlocked())
        .toList();
    unlocked.sort((a, b) {
      final DateTime aDate =
          a.unlockedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bDate =
          b.unlockedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return unlocked.take(3).toList(growable: false);
  }

  static List<HomeQuickStat> _buildQuickStats({
    required double weeklyVolume,
    required int monthlySessions,
    required BodyMetric? latestMetric,
  }) {
    final List<HomeQuickStat> stats = <HomeQuickStat>[
      HomeQuickStat(
        icon: Icons.timeline,
        label: 'Volumen semanal',
        value: '${weeklyVolume.toStringAsFixed(0)} kg',
      ),
      HomeQuickStat(
        icon: Icons.event_available,
        label: 'Entrenamientos mes',
        value: monthlySessions.toString(),
      ),
    ];
    if (latestMetric != null) {
      stats.add(
        HomeQuickStat(
          icon: Icons.monitor_weight_outlined,
          label: 'Último peso',
          value: '${latestMetric.weightKg.toStringAsFixed(1)} kg',
        ),
      );
    }
    return stats;
  }

  static DateTime _nextScheduledDate(DateTime today, Routine routine) {
    final Iterable<int> weekdays = routine.daysOfWeek.map((day) => day.weekday);
    int minDifference = 7;
    for (final int weekday in weekdays) {
      final int diff = (weekday - today.weekday + 7) % 7;
      if (diff < minDifference) {
        minDifference = diff;
      }
    }
    return today.add(Duration(days: minDifference));
  }

  static DateTime _nextOccurrenceOnWeek(DateTime weekStart, int weekday) {
    final int offset = (weekday - DateTime.monday + 7) % 7;
    return weekStart.add(Duration(days: offset));
  }

  static DateTime _startOfWeek(DateTime date) {
    final DateTime normalized = DateTime(date.year, date.month, date.day);
    final int delta = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: delta < 0 ? 6 : delta));
  }

  static MetricDateRange _currentMonthRange(DateTime date) {
    final DateTime start = DateTime(date.year, date.month, 1);
    final DateTime end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    return MetricDateRange(start: start, end: end);
  }

  static String _greetingFor(DateTime now) {
    final int hour = now.hour;
    if (hour < 12) return '¡Buenos días!';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  static String _motivationalMessage(
    DateTime now,
    StreakSnapshot streak,
    RoutineSummary? nextRoutine,
  ) {
    final int hour = now.hour;
    String base;
    if (hour < 12) {
      base = '¿Listo para entrenar?';
    } else if (hour < 18) {
      base = 'Es buen momento para un workout.';
    } else {
      base = 'Registra tu progreso del día.';
    }

    if (streak.currentStreak >= 5) {
      return 'Llevas ${streak.currentStreak} días seguidos. ¡Sigue así!';
    }
    if (nextRoutine != null) {
      final DateTime next = nextRoutine.nextOccurrence;
      final bool today =
          DateTime(next.year, next.month, next.day) ==
          DateTime(now.year, now.month, now.day);
      if (today) {
        return 'Hoy toca ${nextRoutine.name}. ¡A darlo todo!';
      }
    }
    return base;
  }
}
