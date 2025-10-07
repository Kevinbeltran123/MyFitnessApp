import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';

import '../../support/in_memory_routine_repository.dart';

Routine _buildRoutine({
  required String id,
  String name = 'Fuerza total',
  bool archived = false,
}) {
  return Routine(
    id: id,
    name: name,
    description: 'Rutina de ejemplo',
    focus: RoutineFocus.fullBody,
    daysOfWeek: const <RoutineDay>[RoutineDay(DateTime.monday)],
    exercises: <RoutineExercise>[
      const RoutineExercise(
        exerciseId: 'push-up',
        name: 'Push Ups',
        order: 0,
        sets: <RoutineSet>[RoutineSet(setNumber: 1, repetitions: 12)],
        targetMuscles: <String>['Chest'],
      ),
    ],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    notes: 'Notas',
    isArchived: archived,
  );
}

void main() {
  group('RoutineService', () {
    late InMemoryRoutineRepository repository;
    late RoutineService service;

    setUp(() {
      repository = InMemoryRoutineRepository(<Routine>[_buildRoutine(id: 'base')]);
      service = RoutineService(repository: repository);
    });

    test('duplicate creates a new routine with unique id and suffix', () async {
      final Routine duplicated = await service.duplicate('base');

      expect(duplicated.id, isNot('base'));
      expect(duplicated.name, contains('copia'));

      final Routine? stored = await repository.getById(duplicated.id);
      expect(stored, isNotNull);
      expect(stored?.exercises.length, 1);
    });

    test('archive marks routine as archived', () async {
      await service.archive('base');
      final Routine? routine = await repository.getById('base');
      expect(routine?.isArchived, isTrue);
    });

    test('update throws if routine has no exercises', () async {
      final Routine routine = _buildRoutine(id: 'temp').copyWith(exercises: <RoutineExercise>[]);
      expect(() => service.update(routine), throwsFormatException);
    });
  });
}
