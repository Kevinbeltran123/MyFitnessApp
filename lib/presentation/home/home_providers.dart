import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/routines/create_routine.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';
import 'package:my_fitness_tracker/infrastructure/isar/isar_providers.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_repository_isar.dart';
import 'package:my_fitness_tracker/services/api_client.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';

final apiClientProvider = Provider<ApiClient>((Ref ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
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
