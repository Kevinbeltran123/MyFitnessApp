import 'package:isar/isar.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_model.dart';

/// Isar implementation of SessionRepository for workout session persistence.
class SessionRepositoryIsar implements SessionRepository {
  SessionRepositoryIsar(this._isar);

  final Isar _isar;

  @override
  Future<void> saveSession(RoutineSession session) async {
    final model = RoutineSessionModel.fromDomain(session);
    await _isar.writeTxn(() async {
      await _isar.routineSessionModels.put(model);
    });
  }

  @override
  Future<List<RoutineSession>> getAllSessions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Build query based on date filters
    if (startDate != null && endDate != null) {
      final models = await _isar.routineSessionModels
          .filter()
          .startedAtGreaterThan(startDate, include: true)
          .startedAtLessThan(endDate, include: true)
          .sortByStartedAtDesc()
          .findAll();
      return models.map((m) => m.toDomain()).toList();
    } else if (startDate != null) {
      final models = await _isar.routineSessionModels
          .filter()
          .startedAtGreaterThan(startDate, include: true)
          .sortByStartedAtDesc()
          .findAll();
      return models.map((m) => m.toDomain()).toList();
    } else if (endDate != null) {
      final models = await _isar.routineSessionModels
          .filter()
          .startedAtLessThan(endDate, include: true)
          .sortByStartedAtDesc()
          .findAll();
      return models.map((m) => m.toDomain()).toList();
    } else {
      final models = await _isar.routineSessionModels
          .where()
          .sortByStartedAtDesc()
          .findAll();
      return models.map((m) => m.toDomain()).toList();
    }
  }

  @override
  Future<List<RoutineSession>> getSessionsByRoutine(String routineId) async {
    final models = await _isar.routineSessionModels
        .filter()
        .routineIdEqualTo(routineId)
        .sortByStartedAtDesc()
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<RoutineSession?> getLatestSession() async {
    final model = await _isar.routineSessionModels
        .where()
        .sortByStartedAtDesc()
        .findFirst();
    return model?.toDomain();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _isar.writeTxn(() async {
      final model = await _isar.routineSessionModels
          .filter()
          .sessionIdEqualTo(sessionId)
          .findFirst();
      if (model != null) {
        await _isar.routineSessionModels.delete(model.id);
      }
    });
  }

  @override
  Stream<List<RoutineSession>> watchSessions({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Build query based on date filters
    if (startDate != null && endDate != null) {
      return _isar.routineSessionModels
          .filter()
          .startedAtGreaterThan(startDate, include: true)
          .startedAtLessThan(endDate, include: true)
          .sortByStartedAtDesc()
          .watch(fireImmediately: true)
          .map((models) => models.map((m) => m.toDomain()).toList());
    } else if (startDate != null) {
      return _isar.routineSessionModels
          .filter()
          .startedAtGreaterThan(startDate, include: true)
          .sortByStartedAtDesc()
          .watch(fireImmediately: true)
          .map((models) => models.map((m) => m.toDomain()).toList());
    } else if (endDate != null) {
      return _isar.routineSessionModels
          .filter()
          .startedAtLessThan(endDate, include: true)
          .sortByStartedAtDesc()
          .watch(fireImmediately: true)
          .map((models) => models.map((m) => m.toDomain()).toList());
    } else {
      return _isar.routineSessionModels
          .where()
          .sortByStartedAtDesc()
          .watch(fireImmediately: true)
          .map((models) => models.map((m) => m.toDomain()).toList());
    }
  }
}
