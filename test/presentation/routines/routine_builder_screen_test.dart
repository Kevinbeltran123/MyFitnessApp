import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_builder_screen.dart';

import '../../support/fake_workout_service.dart';
import '../../support/in_memory_routine_repository.dart';

void main() {
  testWidgets('RoutineBuilderScreen validates and saves routine', (WidgetTester tester) async {
    final repository = InMemoryRoutineRepository();
    final service = RoutineService(repository: repository);
    final fakeWorkoutService = FakeWorkoutService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          routineRepositoryProvider.overrideWithValue(AsyncValue.data(repository)),
          routineServiceProvider.overrideWithValue(AsyncValue.data(service)),
          workoutServiceProvider.overrideWithValue(fakeWorkoutService),
        ],
        child: const MaterialApp(home: RoutineBuilderScreen()),
      ),
    );

    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('El nombre es obligatorio'), findsOneWidget);

    await tester.enterText(find.bySemanticsLabel('Nombre de la rutina'), 'Mi rutina test');
    await tester.tap(find.text('Agregar ejercicio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final routines = await repository.watchAll(includeArchived: true).first;
    expect(routines.any((Routine r) => r.name == 'Mi rutina test'), isTrue);
  });
}
