import 'package:isar/isar.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_model.dart';

class RoutineRepositoryIsar implements RoutineRepository {
  RoutineRepositoryIsar(this._isar);

  final Isar _isar;

  @override
  Stream<List<Routine>> watchAll({bool includeArchived = false}) {
    final collection = _isar.routineModels;
    final query = includeArchived
        ? collection.where().sortByCreatedAtDesc()
        : collection.filter().isArchivedEqualTo(false).sortByCreatedAtDesc();
    return query
        .watch(fireImmediately: true)
        .map(
          (List<RoutineModel> models) => models
              .map((RoutineModel m) => m.toDomain())
              .toList(growable: false),
        );
  }

  @override
  Future<Routine?> getById(String id) async {
    final model = await _isar.routineModels
        .filter()
        .routineIdEqualTo(id)
        .findFirst();
    return model?.toDomain();
  }

  @override
  Future<void> saveRoutine(Routine routine) async {
    final model = RoutineModel.fromDomain(
      routine.copyWith(updatedAt: DateTime.now()),
    );
    await _isar.writeTxn(() async {
      await _isar.routineModels.put(model);
    });
  }

  @override
  Future<void> deleteRoutine(String id, {bool hardDelete = false}) async {
    await _isar.writeTxn(() async {
      if (hardDelete) {
        final model = await _isar.routineModels
            .filter()
            .routineIdEqualTo(id)
            .findFirst();
        if (model != null) {
          await _isar.routineModels.delete(model.id);
        }
        await _isar.routineSessionModels
            .filter()
            .routineIdEqualTo(id)
            .deleteAll();
        return;
      }

      final model = await _isar.routineModels
          .filter()
          .routineIdEqualTo(id)
          .findFirst();
      if (model != null) {
        model.isArchived = true;
        model.updatedAt = DateTime.now();
        await _isar.routineModels.put(model);
      }
    });
  }

  @override
  Future<void> reorderExercises(
    String routineId,
    List<String> orderedExerciseIds,
  ) async {
    await _isar.writeTxn(() async {
      final model = await _isar.routineModels
          .filter()
          .routineIdEqualTo(routineId)
          .findFirst();
      if (model == null) {
        return;
      }
      final orderMap = <String, int>{
        for (int i = 0; i < orderedExerciseIds.length; i += 1)
          orderedExerciseIds[i]: i,
      };
      model.exercises.sort((RoutineExerciseModel a, RoutineExerciseModel b) {
        final orderA = orderMap[a.exerciseId];
        final orderB = orderMap[b.exerciseId];
        return (orderA ?? a.order).compareTo(orderB ?? b.order);
      });
      for (int i = 0; i < model.exercises.length; i += 1) {
        model.exercises[i].order = i;
      }
      model.updatedAt = DateTime.now();
      await _isar.routineModels.put(model);
    });
  }

  @override
  Future<void> upsertSession(RoutineSession session) async {
    final model = RoutineSessionModel.fromDomain(session);
    await _isar.writeTxn(() async {
      await _isar.routineSessionModels.put(model);
    });
  }

  @override
  Stream<List<RoutineSession>> watchSessions({String? routineId}) {
    final collection = _isar.routineSessionModels;
    final query = routineId == null
        ? collection.where().sortByStartedAtDesc()
        : collection.filter().routineIdEqualTo(routineId).sortByStartedAtDesc();
    return query
        .watch(fireImmediately: true)
        .map(
          (List<RoutineSessionModel> models) => models
              .map((RoutineSessionModel m) => m.toDomain())
              .toList(growable: false),
        );
  }
}
