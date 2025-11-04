import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/analytics/personal_record_service.dart';
import 'package:my_fitness_tracker/application/gamification/achievement_service.dart';
import 'package:my_fitness_tracker/application/gamification/streak_tracker.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart'
    hide metricsRepositoryProvider;
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';

final streakMilestoneProvider = StateProvider<int?>((ref) => null);
final seenAchievementsProvider = StateProvider<Set<String>>((ref) => <String>{});

/// Provides a configured [StreakTracker] instance.
final streakTrackerProvider = FutureProvider<StreakTracker>((ref) async {
  final sessionRepository = await ref.watch(sessionRepositoryProvider.future);
  return StreakTracker(sessionRepository: sessionRepository);
});

/// Provides the [AchievementService] with all dependencies wired up.
final achievementServiceProvider = FutureProvider<AchievementService>((ref) async {
  final RoutineRepository routineRepository =
      await ref.watch(routineRepositoryProvider.future);
  final SessionRepository sessionRepository =
      await ref.watch(sessionRepositoryProvider.future);
  final MetricsRepository metricsRepository =
      await ref.watch(metricsRepositoryProvider.future);
  final StreakTracker streakTracker =
      await ref.watch(streakTrackerProvider.future);
  final personalRecordService = PersonalRecordService(
    sessionRepository: sessionRepository,
    calculator: ref.watch(oneRepMaxCalculatorProvider),
  );

  return AchievementService(
    routineRepository: routineRepository,
    sessionRepository: sessionRepository,
    metricsRepository: metricsRepository,
    personalRecordService: personalRecordService,
    streakTracker: streakTracker,
  );
});

/// Stream of achievements. Recomputes whenever routines, sessions or metrics change.
final achievementsProvider = StreamProvider<List<Achievement>>((ref) async* {
  final RoutineRepository routineRepository =
      await ref.watch(routineRepositoryProvider.future);
  final SessionRepository sessionRepository =
      await ref.watch(sessionRepositoryProvider.future);
  final MetricsRepository metricsRepository =
      await ref.watch(metricsRepositoryProvider.future);
  final AchievementService service =
      await ref.watch(achievementServiceProvider.future);

  final Stream<List<Routine>> routines$ =
      routineRepository.watchAll(includeArchived: true);
  final Stream<List<RoutineSession>> sessions$ =
      sessionRepository.watchSessions();
  final Stream<List<BodyMetric>> metrics$ = metricsRepository.watchMetrics();

  final controller = StreamController<List<Achievement>>();

  Future<void> recompute() async {
    final achievements = await service.evaluateAchievements();
    if (!controller.isClosed) {
      controller.add(achievements);
    }
  }

  late final StreamSubscription<List<Routine>> routinesSub;
  late final StreamSubscription<List<RoutineSession>> sessionsSub;
  late final StreamSubscription<List<BodyMetric>> metricsSub;

  routinesSub = routines$.listen((_) => recompute());
  sessionsSub = sessions$.listen((_) => recompute());
  metricsSub = metrics$.listen((_) => recompute());

  ref.onDispose(() async {
    await routinesSub.cancel();
    await sessionsSub.cancel();
    await metricsSub.cancel();
    await controller.close();
  });

  await recompute();
  yield* controller.stream;
});

/// Provides the latest streak snapshot for the current range.
final currentStreakProvider = FutureProvider<StreakSnapshot>((ref) async {
  final streakTracker = await ref.watch(streakTrackerProvider.future);
  final snapshot = await streakTracker.buildSnapshot(lookBackDays: 30);
  final milestoneNotifier = ref.read(streakMilestoneProvider.notifier);
  final int? previous = milestoneNotifier.state;
  final int? currentMilestone = snapshot.milestoneReached;
  if (currentMilestone != null &&
      (previous == null || currentMilestone > previous)) {
    milestoneNotifier.state = currentMilestone;
  }
  return snapshot;
});
