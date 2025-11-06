import 'package:my_fitness_tracker/application/routines/create_routine.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';
import 'package:uuid/uuid.dart';

class RoutineService {
  RoutineService({required RoutineRepository repository})
    : _repository = repository,
      _createRoutine = CreateRoutine(repository);

  final RoutineRepository _repository;
  final CreateRoutine _createRoutine;
  static const Uuid _uuid = Uuid();

  Future<void> create(Routine routine) => _createRoutine(routine);

  Future<Routine?> getRoutine(String routineId) {
    return _repository.getById(routineId);
  }

  Future<void> update(Routine routine) async {
    if (!routine.hasExercises) {
      throw const FormatException(
        'La rutina debe contener al menos un ejercicio.',
      );
    }
    await _repository.saveRoutine(routine.copyWith(updatedAt: DateTime.now()));
  }

  Future<Routine> duplicate(String routineId, {String? newName}) async {
    final routine = await _repository.getById(routineId);
    if (routine == null) {
      throw ArgumentError('Routine with id "$routineId" does not exist.');
    }

    final DateTime now = DateTime.now();
    final cloned = Routine(
      id: _uuid.v4(),
      name: newName ?? '${routine.name} (copia)',
      description: routine.description,
      focus: routine.focus,
      daysOfWeek: List<RoutineDay>.from(routine.daysOfWeek),
      exercises: List<RoutineExercise>.from(routine.exercises),
      createdAt: now,
      updatedAt: now,
      notes: routine.notes,
      isArchived: false,
    );

    await _createRoutine(cloned);
    return cloned;
  }

  Future<void> archive(String routineId) async {
    final routine = await _repository.getById(routineId);
    if (routine == null) {
      return;
    }
    await _repository.saveRoutine(
      routine.copyWith(isArchived: true, updatedAt: DateTime.now()),
    );
  }

  Future<void> restore(String routineId) async {
    final routine = await _repository.getById(routineId);
    if (routine == null) {
      return;
    }
    await _repository.saveRoutine(
      routine.copyWith(isArchived: false, updatedAt: DateTime.now()),
    );
  }

  Future<void> delete(String routineId, {bool hardDelete = false}) {
    return _repository.deleteRoutine(routineId, hardDelete: hardDelete);
  }

  Future<void> reorderExercises(
    String routineId,
    List<String> orderedExerciseIds,
  ) {
    return _repository.reorderExercises(routineId, orderedExerciseIds);
  }

  Future<void> logSession(RoutineSession session) {
    return _repository.upsertSession(session);
  }
}
