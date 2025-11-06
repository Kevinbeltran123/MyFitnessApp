part of 'package:my_fitness_tracker/presentation/home/home_controller.dart';

class HomeDashboardState {
  const HomeDashboardState({
    required this.generatedAt,
    required this.greeting,
    required this.motivationalMessage,
    required this.streakSnapshot,
    required this.nextRoutine,
    required this.quickStats,
    required this.sparkline,
    required this.calendar,
    required this.recentAchievements,
    required this.latestMetric,
    required this.weeklyVolume,
    required this.monthlySessions,
  });

  final DateTime generatedAt;
  final String greeting;
  final String motivationalMessage;
  final StreakSnapshot streakSnapshot;
  final RoutineSummary? nextRoutine;
  final List<HomeQuickStat> quickStats;
  final List<MetricSparkPoint> sparkline;
  final List<HomeCalendarDay> calendar;
  final List<Achievement> recentAchievements;
  final BodyMetric? latestMetric;
  final double weeklyVolume;
  final int monthlySessions;

  bool get hasSparkline => sparkline.length >= 2;
  bool get hasRecentAchievements => recentAchievements.isNotEmpty;
}

class RoutineSummary {
  const RoutineSummary({
    required this.routineId,
    required this.name,
    required this.focus,
    required this.nextOccurrence,
    this.lastCompletedAt,
  });

  final String routineId;
  final String name;
  final RoutineFocus focus;
  final DateTime nextOccurrence;
  final DateTime? lastCompletedAt;
}

class HomeQuickStat {
  const HomeQuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class MetricSparkPoint {
  const MetricSparkPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class HomeCalendarDay {
  const HomeCalendarDay({
    required this.date,
    required this.scheduledRoutines,
    required this.isCompleted,
  });

  final DateTime date;
  final List<RoutineSummary> scheduledRoutines;
  final bool isCompleted;

  bool get hasRoutines => scheduledRoutines.isNotEmpty;
}
