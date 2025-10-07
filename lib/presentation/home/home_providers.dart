import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/routines/create_routine.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';
import 'package:my_fitness_tracker/infrastructure/isar/isar_providers.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_repository_isar.dart';
import 'package:my_fitness_tracker/services/api_client.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';
import 'package:my_fitness_tracker/application/timers/rest_timer_service.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/infrastructure/metrics/in_memory_metrics_repository.dart';

final apiClientProvider = Provider<ApiClient>((Ref ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});

final metricsRepositoryProvider = Provider<MetricsRepository>((Ref ref) {
  final repository = InMemoryMetricsRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final restTimerEngineProvider = Provider<RestTimerEngine>((Ref ref) {
  final engine = InMemoryRestTimerEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

final restTimerManagerProvider = Provider<RestTimerManager>((Ref ref) {
  final engine = ref.watch(restTimerEngineProvider);
  return RestTimerManager(engine: engine);
});

final workoutServiceProvider = Provider<WorkoutService>((Ref ref) {
  final client = ref.watch(apiClientProvider);
  return WorkoutService(client);
});

final routineRepositoryProvider = FutureProvider<RoutineRepository>((
  Ref ref,
) async {
  final isar = await ref.watch(isarProvider.future);
  return RoutineRepositoryIsar(isar);
});

final routineLastUsedProvider = StreamProvider<Map<String, DateTime>>((
  Ref ref,
) async* {
  final repository = await ref.watch(routineRepositoryProvider.future);
  await for (final List<RoutineSession> sessions
      in repository.watchSessions()) {
    final Map<String, DateTime> aggregated = <String, DateTime>{};
    for (final RoutineSession session in sessions) {
      final DateTime completedAt = session.completedAt;
      final DateTime? existing = aggregated[session.routineId];
      if (existing == null || completedAt.isAfter(existing)) {
        aggregated[session.routineId] = completedAt;
      }
    }
    yield Map<String, DateTime>.unmodifiable(aggregated);
  }
});

final watchAllRoutinesProvider = StreamProvider<List<Routine>>((
  Ref ref,
) async* {
  final repo = await ref.watch(routineRepositoryProvider.future);
  yield* repo.watchAll();
});

final createRoutineUseCaseProvider = FutureProvider<CreateRoutine>((
  Ref ref,
) async {
  final repo = await ref.watch(routineRepositoryProvider.future);
  return CreateRoutine(repo);
});

final routineServiceProvider = FutureProvider<RoutineService>((Ref ref) async {
  final repo = await ref.watch(routineRepositoryProvider.future);
  return RoutineService(repository: repo);
});

final routineByIdProvider = FutureProvider.autoDispose.family<Routine?, String>(
  (Ref ref, String id) async {
    final repo = await ref.watch(routineRepositoryProvider.future);
    return repo.getById(id);
  },
);
