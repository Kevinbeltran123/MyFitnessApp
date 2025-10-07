import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_detail_screen.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_session_screen.dart';

import '../../support/fake_workout_service.dart';
import '../../support/in_memory_routine_repository.dart';

Routine _routine(
  String id, {
  bool archived = false,
  String name = 'Rutina base',
}) {
  return Routine(
    id: id,
    name: name,
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
  testWidgets('RoutineDetailScreen shows routine data and archives/restores', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryRoutineRepository(<Routine>[_routine('base')]);
    final service = RoutineService(repository: repository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          routineRepositoryProvider.overrideWith((Ref ref) async => repository),
          routineServiceProvider.overrideWith((Ref ref) async => service),
          workoutServiceProvider.overrideWithValue(FakeWorkoutService()),
        ],
        child: const MaterialApp(home: RoutineDetailScreen(routineId: 'base')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rutina base'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    final archived = await repository.getById('base');
    expect(archived?.isArchived, isTrue);
  });

  testWidgets(
    'RoutineDetailScreen allows quick edit and live mode navigation',
    (WidgetTester tester) async {
      final repository = InMemoryRoutineRepository(<Routine>[_routine('base')]);
      final service = RoutineService(repository: repository);
      final fakeWorkoutService = FakeWorkoutService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            routineRepositoryProvider.overrideWith(
              (Ref ref) async => repository,
            ),
            routineServiceProvider.overrideWith((Ref ref) async => service),
            workoutServiceProvider.overrideWithValue(fakeWorkoutService),
          ],
          child: const MaterialApp(
            home: RoutineDetailScreen(routineId: 'base'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Editar rutina'), findsOneWidget);

      await tester.enterText(
        find.bySemanticsLabel('Nombre de la rutina'),
        'Rutina base editada',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Rutina base editada'), findsOneWidget);

      await tester.tap(find.text('Iniciar entrenamiento'));
      await tester.pumpAndSettle();

      expect(find.byType(RoutineSessionScreen), findsOneWidget);
    },
  );
}
