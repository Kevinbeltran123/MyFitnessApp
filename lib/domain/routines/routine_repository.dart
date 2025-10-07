import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';

/// Contract for persisting and retrieving routines and their sessions.
abstract class RoutineRepository {
  Stream<List<Routine>> watchAll({bool includeArchived = false});

  Future<Routine?> getById(String id);

  Future<void> saveRoutine(Routine routine);

  Future<void> deleteRoutine(String id, {bool hardDelete = false});

  Future<void> reorderExercises(
    String routineId,
    List<String> orderedExerciseIds,
  );

  Future<void> upsertSession(RoutineSession session);

  Stream<List<RoutineSession>> watchSessions({String? routineId});
}
