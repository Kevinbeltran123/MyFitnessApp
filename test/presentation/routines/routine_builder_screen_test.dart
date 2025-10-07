import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_builder_screen.dart';

import '../../support/fake_workout_service.dart';
import '../../support/in_memory_routine_repository.dart';

Routine _existingRoutine(String id, {String name = 'Rutina base'}) {
  return Routine(
    id: id,
    name: name,
    description: 'Demo de rutina',
    focus: RoutineFocus.fullBody,
    daysOfWeek: const <RoutineDay>[RoutineDay(DateTime.monday)],
    exercises: const <RoutineExercise>[
      RoutineExercise(
        exerciseId: 'push-up',
        name: 'Push Ups',
        order: 0,
        sets: <RoutineSet>[RoutineSet(setNumber: 1, repetitions: 12)],
        targetMuscles: <String>['Chest'],
        equipment: 'Bodyweight',
        gifUrl: '',
      ),
    ],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    notes: null,
    isArchived: false,
  );
}

void main() {
  testWidgets('RoutineBuilderScreen validates and saves routine', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryRoutineRepository();
    final service = RoutineService(repository: repository);
    final fakeWorkoutService = FakeWorkoutService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          routineRepositoryProvider.overrideWith((Ref ref) async => repository),
          routineServiceProvider.overrideWith((Ref ref) async => service),
          workoutServiceProvider.overrideWithValue(fakeWorkoutService),
        ],
        child: const MaterialApp(home: RoutineBuilderScreen()),
      ),
    );

    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('El nombre es obligatorio'), findsOneWidget);

    await tester.enterText(
      find.bySemanticsLabel('Nombre de la rutina'),
      'Mi rutina test',
    );
    await tester.tap(find.text('Agregar ejercicio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final routines = await repository.watchAll(includeArchived: true).first;
    expect(routines.any((Routine r) => r.name == 'Mi rutina test'), isTrue);
  });

  testWidgets('RoutineBuilderScreen preloads existing routine and updates it', (
    WidgetTester tester,
  ) async {
    final existing = _existingRoutine('existing');
    final repository = InMemoryRoutineRepository(<Routine>[existing]);
    final service = RoutineService(repository: repository);
    final fakeWorkoutService = FakeWorkoutService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          routineRepositoryProvider.overrideWith((Ref ref) async => repository),
          routineServiceProvider.overrideWith((Ref ref) async => service),
          workoutServiceProvider.overrideWithValue(fakeWorkoutService),
        ],
        child: MaterialApp(
          home: RoutineBuilderScreen(initialRoutine: existing),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar rutina'), findsOneWidget);
    expect(find.text('Rutina base'), findsOneWidget);

    await tester.enterText(
      find.bySemanticsLabel('Nombre de la rutina'),
      'Rutina actualizada',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final updated = await repository.getById('existing');
    expect(updated?.name, 'Rutina actualizada');
  });
}
