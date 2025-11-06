import 'dart:math';

import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';

/// Summary about the user's streak status.
class StreakSnapshot {
  const StreakSnapshot({
    required this.currentStreak,
    required this.longestStreak,
    required this.recentActiveDays,
    required this.streakBroken,
    this.milestoneReached,
  });

  final int currentStreak;
  final int longestStreak;
  final List<DateTime> recentActiveDays;
  final bool streakBroken;
  final int? milestoneReached;
}

/// Calculates training streak data from completed workout sessions.
class StreakTracker {
  StreakTracker({
    required SessionRepository sessionRepository,
    List<int>? milestoneThresholds,
  })  : _sessionRepository = sessionRepository,
        _milestones = _prepareMilestones(milestoneThresholds);

  final SessionRepository _sessionRepository;
  final List<int> _milestones;

  static List<int> _prepareMilestones(List<int>? milestoneThresholds) {
    final List<int> thresholds = List<int>.from(
      milestoneThresholds ?? const <int>[3, 7, 14, 30, 60, 90],
    );
    thresholds.sort();
    return List<int>.unmodifiable(thresholds);
  }

  Future<StreakSnapshot> buildSnapshot({
    DateTime? anchor,
    int lookBackDays = 30,
  }) async {
    final DateTime today = _startOfDay(anchor ?? DateTime.now());
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions();
    if (sessions.isEmpty) {
      return const StreakSnapshot(
        currentStreak: 0,
        longestStreak: 0,
        recentActiveDays: <DateTime>[],
        streakBroken: false,
        milestoneReached: null,
      );
    }

    final Set<DateTime> activeDays = sessions
        .map((session) => _startOfDay(session.completedAt))
        .toSet();
    final List<DateTime> sortedDays = activeDays.toList()..sort();

    final int longest = _calculateLongestStreak(sortedDays);
    final int current = _calculateCurrentStreak(sortedDays, today);

    final DateTime mostRecent = sortedDays.last;
    final bool streakBroken =
        current == 0 && today.difference(mostRecent).inDays > 1;

    final int? milestoneReached = _milestones
        .where((threshold) => current >= threshold)
        .fold<int?>(null, (prev, threshold) => threshold);

    final List<DateTime> recentActiveDays = List<DateTime>.generate(
      lookBackDays,
      (index) => today.subtract(Duration(days: index)),
    ).where(activeDays.contains).toList();

    return StreakSnapshot(
      currentStreak: current,
      longestStreak: max(longest, current),
      recentActiveDays: recentActiveDays,
      streakBroken: streakBroken,
      milestoneReached: milestoneReached,
    );
  }

  Future<int> currentStreak({DateTime? anchor}) async {
    final StreakSnapshot snapshot = await buildSnapshot(
      anchor: anchor,
      lookBackDays: 0,
    );
    return snapshot.currentStreak;
  }

  Future<int> longestStreak() async {
    final List<RoutineSession> sessions = await _sessionRepository
        .getAllSessions();
    if (sessions.isEmpty) {
      return 0;
    }
    final List<DateTime> days =
        sessions
            .map((session) => _startOfDay(session.completedAt))
            .toSet()
            .toList()
          ..sort();
    return _calculateLongestStreak(days);
  }

  int _calculateCurrentStreak(List<DateTime> sortedDays, DateTime anchor) {
    int streak = 0;
    DateTime cursor = anchor;
    final Set<DateTime> active = sortedDays.toSet();
    while (active.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _calculateLongestStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) {
      return 0;
    }
    int longest = 1;
    int streak = 1;
    for (int i = 1; i < sortedDays.length; i += 1) {
      final DateTime previous = sortedDays[i - 1];
      final DateTime current = sortedDays[i];
      if (current.difference(previous).inDays == 1) {
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
    return longest;
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
