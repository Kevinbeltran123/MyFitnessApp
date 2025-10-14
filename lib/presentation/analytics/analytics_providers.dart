import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/analytics/analytics_service.dart';
import 'package:my_fitness_tracker/application/analytics/one_rep_max_calculator.dart';
import 'package:my_fitness_tracker/application/analytics/personal_record_service.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';

final oneRepMaxCalculatorProvider = Provider<OneRepMaxCalculator>((ref) {
  return const OneRepMaxCalculator();
});

final analyticsServiceProvider = FutureProvider<AnalyticsService>((ref) async {
  final sessionRepository = await ref.watch(sessionRepositoryProvider.future);
  final calculator = ref.watch(oneRepMaxCalculatorProvider);
  return AnalyticsService(
    sessionRepository: sessionRepository,
    calculator: calculator,
  );
});

final personalRecordServiceProvider = FutureProvider<PersonalRecordService>((
  ref,
) async {
  final sessionRepository = await ref.watch(sessionRepositoryProvider.future);
  final calculator = ref.watch(oneRepMaxCalculatorProvider);
  return PersonalRecordService(
    sessionRepository: sessionRepository,
    calculator: calculator,
  );
});

final personalRecordsProvider = StreamProvider<List<PersonalRecord>>((
  ref,
) async* {
  final service = await ref.watch(personalRecordServiceProvider.future);
  yield* service.watchPersonalRecords();
});

final personalRecordByExerciseProvider =
    StreamProvider.family<PersonalRecord?, String>((ref, exerciseId) async* {
      final service = await ref.watch(personalRecordServiceProvider.future);
      yield* service.watchRecordByExercise(exerciseId);
    });

final weeklyVolumeProvider = FutureProvider.family<double, DateTime>((
  ref,
  date,
) async {
  final service = await ref.watch(analyticsServiceProvider.future);
  return service.calculateWeeklyVolume(date);
});

final consistencyMetricsProvider =
    FutureProvider.family<double, MetricDateRange>((ref, range) async {
      final service = await ref.watch(analyticsServiceProvider.future);
      return service.calculateConsistency(range);
    });

final muscleGroupStatsProvider =
    FutureProvider.family<List<MuscleGroupStat>, MetricDateRange>((
      ref,
      range,
    ) async {
      final service = await ref.watch(analyticsServiceProvider.future);
      return service.getMuscleGroupStats(range);
    });

final workoutStatsProvider =
    FutureProvider.family<WorkoutStats, MetricDateRange>((ref, range) async {
      final service = await ref.watch(analyticsServiceProvider.future);
      return service.buildWorkoutStats(range);
    });

final exerciseProgressProvider =
    FutureProvider.family<ExerciseProgress, ExerciseProgressParams>((
      ref,
      params,
    ) async {
      final service = await ref.watch(analyticsServiceProvider.future);
      return service.getExerciseProgress(params.exerciseId, params.range);
    });

class ExerciseProgressParams {
  const ExerciseProgressParams({required this.exerciseId, required this.range});

  final String exerciseId;
  final MetricDateRange range;
}
