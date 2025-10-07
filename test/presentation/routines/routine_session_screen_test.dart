import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_session_screen.dart';

import '../../support/in_memory_routine_repository.dart';

Routine _singleSetRoutine() {
  return Routine(
    id: 'unit-test-routine',
    name: 'Sesión rápida',
    description: 'Test',
    focus: RoutineFocus.fullBody,
    daysOfWeek: const <RoutineDay>[RoutineDay(DateTime.tuesday)],
    exercises: const <RoutineExercise>[
      RoutineExercise(
        exerciseId: 'squat',
        name: 'Sentadillas',
        order: 0,
        sets: <RoutineSet>[
          RoutineSet(setNumber: 1, repetitions: 10, targetWeight: 60),
        ],
        targetMuscles: <String>['Piernas'],
        notes: null,
        equipment: 'Barra',
        gifUrl: '',
      ),
    ],
    createdAt: DateTime(2024, 2, 1),
    updatedAt: DateTime(2024, 2, 1),
    notes: null,
    isArchived: false,
  );
}

void main() {
  testWidgets(
    'RoutineSessionScreen permite registrar una serie y muestra resumen',
    (WidgetTester tester) async {
      final Routine routine = _singleSetRoutine();
      final repository = InMemoryRoutineRepository(<Routine>[routine]);
      final service = RoutineService(repository: repository);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            routineRepositoryProvider.overrideWith(
              (Ref ref) async => repository,
            ),
            routineServiceProvider.overrideWith((Ref ref) async => service),
          ],
          child: const MaterialApp(
            home: RoutineSessionScreen(routineId: 'unit-test-routine'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sentadillas'), findsOneWidget);

      await tester.tap(find.text('Registrar serie'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar serie'));
      await tester.pumpAndSettle();

      expect(find.text('¡Sesión completada! 🎉'), findsOneWidget);
    },
  );
}
