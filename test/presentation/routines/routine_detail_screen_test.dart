import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_detail_screen.dart';

import '../../support/in_memory_routine_repository.dart';

Routine _routine(String id, {bool archived = false}) {
  return Routine(
    id: id,
    name: 'Rutina $id',
    description: 'Demo',
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
    isArchived: archived,
  );
}

void main() {
  testWidgets('RoutineDetailScreen shows routine data and archives/restores', (WidgetTester tester) async {
    final repository = InMemoryRoutineRepository(<Routine>[_routine('base')]);
    final service = RoutineService(repository: repository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          routineRepositoryProvider.overrideWithValue(AsyncValue.data(repository)),
          routineServiceProvider.overrideWithValue(AsyncValue.data(service)),
        ],
        child: const MaterialApp(
          home: RoutineDetailScreen(routineId: 'base'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rutina base'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    final archived = await repository.getById('base');
    expect(archived?.isArchived, isTrue);
  });
}
