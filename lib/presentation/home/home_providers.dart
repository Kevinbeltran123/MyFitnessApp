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

final routineRepositoryProvider = Provider<AsyncValue<RoutineRepository>>((
  Ref ref,
) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenData(RoutineRepositoryIsar.new);
});

final watchAllRoutinesProvider = StreamProvider<List<Routine>>((
  Ref ref,
) async* {
  final repoAsync = ref.watch(routineRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    yield const <Routine>[];
    return;
  }
  yield* repo.watchAll();
});

final createRoutineUseCaseProvider = Provider<AsyncValue<CreateRoutine>>((
  Ref ref,
) {
  final repoAsync = ref.watch(routineRepositoryProvider);
  return repoAsync.whenData(CreateRoutine.new);
});

final routineServiceProvider = Provider<AsyncValue<RoutineService>>((Ref ref) {
  final repoAsync = ref.watch(routineRepositoryProvider);
  return repoAsync.whenData((RoutineRepository repo) => RoutineService(repository: repo));
});

final routineByIdProvider = FutureProvider.autoDispose.family<Routine?, String>((Ref ref, String id) async {
  final repoAsync = ref.watch(routineRepositoryProvider);
  final repo = repoAsync.value;
  if (repo == null) {
    return null;
  }
  return repo.getById(id);
});
