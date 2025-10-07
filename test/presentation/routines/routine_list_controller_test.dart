import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';

import '../../support/in_memory_routine_repository.dart';

Routine _routine(String id, {String name = 'Rutina'}) {
  return Routine(
    id: id,
    name: name,
    description: 'Demo',
    focus: RoutineFocus.fullBody,
    daysOfWeek: const <RoutineDay>[RoutineDay(DateTime.monday)],
    exercises: <RoutineExercise>[
      const RoutineExercise(
        exerciseId: 'id-1',
        name: 'Push Ups',
        order: 0,
        sets: <RoutineSet>[RoutineSet(setNumber: 1, repetitions: 10)],
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
  group('RoutineListController', () {
    test('emits existing routines on first load', () async {
      final InMemoryRoutineRepository repository =
          InMemoryRoutineRepository(<Routine>[_routine('r-1', name: 'Fuerza')]);

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          routineRepositoryProvider.overrideWithValue(AsyncValue.data(repository)),
        ],
      );
      addTearDown(container.dispose);

      final List<Routine> routines = await container.read(routineListControllerProvider.future);
      expect(routines, hasLength(1));
      expect(routines.first.name, 'Fuerza');
    });

    test('refresh reloads routines after repository updates', () async {
      final InMemoryRoutineRepository repository =
          InMemoryRoutineRepository(<Routine>[_routine('r-1')]);

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          routineRepositoryProvider.overrideWithValue(AsyncValue.data(repository)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(routineListControllerProvider.future);
      await repository.saveRoutine(_routine('r-2', name: 'Nueva')); // emit change
      await container.read(routineListControllerProvider.notifier).refresh();
      final AsyncValue<List<Routine>> state = container.read(routineListControllerProvider);
      expect(state.value, isNotNull);
      expect(state.value, hasLength(2));
    });
  });
}
