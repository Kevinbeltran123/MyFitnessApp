import 'dart:async';

import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';

class InMemoryRoutineRepository implements RoutineRepository {
  InMemoryRoutineRepository([Iterable<Routine> routines = const <Routine>[]]) {
    for (final Routine routine in routines) {
      _routines[routine.id] = routine;
    }
  }

  final Map<String, Routine> _routines = <String, Routine>{};
  final Map<String, RoutineSession> _sessions = <String, RoutineSession>{};
  final StreamController<List<Routine>> _routineStreamController =
      StreamController<List<Routine>>.broadcast();
  final StreamController<List<RoutineSession>> _sessionStreamController =
      StreamController<List<RoutineSession>>.broadcast();

  void _emitRoutines() {
    _routineStreamController.add(_routines.values.toList(growable: false));
  }

  @override
  Stream<List<Routine>> watchAll({bool includeArchived = false}) {
    Future<void>.microtask(_emitRoutines);
    return includeArchived
        ? _routineStreamController.stream
        : _routineStreamController.stream.map(
            (List<Routine> routines) => routines
                .where((Routine routine) => !routine.isArchived)
                .toList(growable: false),
          );
  }

  @override
  Future<Routine?> getById(String id) async => _routines[id];

  @override
  Future<void> saveRoutine(Routine routine) async {
    _routines[routine.id] = routine;
    _emitRoutines();
  }

  @override
  Future<void> deleteRoutine(String id, {bool hardDelete = false}) async {
    _routines.remove(id);
    _emitRoutines();
  }

  @override
  Future<void> reorderExercises(String routineId, List<String> orderedExerciseIds) async {
    final Routine? routine = _routines[routineId];
    if (routine == null) {
      return;
    }
    final Map<String, int> orderMap = <String, int>{
      for (int i = 0; i < orderedExerciseIds.length; i += 1)
        orderedExerciseIds[i]: i,
    };
    final List<RoutineExercise> ordered = List<RoutineExercise>.from(routine.exercises)
      ..sort((RoutineExercise a, RoutineExercise b) {
        final int orderA = orderMap[a.exerciseId] ?? a.order;
        final int orderB = orderMap[b.exerciseId] ?? b.order;
        return orderA.compareTo(orderB);
      });
    _routines[routineId] = routine.copyWith(exercises: ordered, updatedAt: DateTime.now());
    _emitRoutines();
  }

  @override
  Future<void> upsertSession(RoutineSession session) async {
    _sessions[session.id] = session;
    _sessionStreamController.add(_sessions.values.toList(growable: false));
  }

  @override
  Stream<List<RoutineSession>> watchSessions({String? routineId}) {
    Future<void>.microtask(() {
      _sessionStreamController.add(_sessions.values.toList(growable: false));
    });
    return _sessionStreamController.stream;
  }
}
