import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/infrastructure/isar/isar_providers.dart';
import 'package:my_fitness_tracker/infrastructure/sessions/session_repository_isar.dart';

/// Provider for the session repository
final sessionRepositoryProvider = FutureProvider<SessionRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return SessionRepositoryIsar(isar);
});

/// Provider for workout history - watches all sessions
final workoutHistoryControllerProvider =
    StreamProvider<List<RoutineSession>>((ref) async* {
  final repository = await ref.watch(sessionRepositoryProvider.future);
  yield* repository.watchSessions();
});

/// Provider for sessions by routine ID
final sessionsByRoutineProvider =
    FutureProvider.family<List<RoutineSession>, String>((ref, routineId) async {
  final repository = await ref.watch(sessionRepositoryProvider.future);
  return repository.getSessionsByRoutine(routineId);
});
