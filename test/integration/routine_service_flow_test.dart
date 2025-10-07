import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';

import '../support/in_memory_routine_repository.dart';

Routine _routine(String id) {
  return Routine(
    id: id,
    name: 'Rutina $id',
    description: 'Demo',
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
    notes: null,
    isArchived: false,
  );
}

void main() {
  test('Routine service flow updates controller state', () async {
    final repository = InMemoryRoutineRepository(<Routine>[_routine('base')]);
    final container = ProviderContainer(
      overrides: <Override>[
        routineRepositoryProvider.overrideWithValue(AsyncValue.data(repository)),
      ],
    );
    addTearDown(container.dispose);

    final RoutineService service = container.read(routineServiceProvider).value!;

    // Create new routine
    final DateTime now = DateTime.now();
    final routine = Routine(
      id: 'created',
      name: 'Nueva',
      description: 'Rutina creada vía servicio',
      focus: RoutineFocus.fullBody,
      daysOfWeek: const <RoutineDay>[RoutineDay(DateTime.monday)],
      exercises: <RoutineExercise>[
        const RoutineExercise(
          exerciseId: 'push-up',
          name: 'Push Ups',
          order: 0,
          sets: <RoutineSet>[RoutineSet(setNumber: 1, repetitions: 8)],
          targetMuscles: <String>['Chest'],
        ),
      ],
      createdAt: now,
      updatedAt: now,
      notes: null,
      isArchived: false,
    );

    await service.create(routine);
    await container.read(routineListControllerProvider.notifier).refresh();
    final List<Routine> afterCreate =
        await container.read(routineListControllerProvider.future);
    expect(afterCreate.any((Routine r) => r.id == 'created'), isTrue);

    // Duplicate
    final Routine duplicated = await service.duplicate('created', newName: 'Duplicada');
    await container.read(routineListControllerProvider.notifier).refresh();
    final List<Routine> afterDuplicate =
        await container.read(routineListControllerProvider.future);
    expect(afterDuplicate.any((Routine r) => r.id == duplicated.id), isTrue);

    // Archive
    await service.archive('created');
    await container.read(routineListControllerProvider.notifier).refresh();
    final List<Routine> afterArchive =
        await container.read(routineListControllerProvider.future);
    final Routine archived = afterArchive.firstWhere((Routine r) => r.id == 'created');
    expect(archived.isArchived, isTrue);
  });
}
