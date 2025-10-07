import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_session_controller.dart';

import '../../support/in_memory_routine_repository.dart';

Routine _buildRoutine() {
  return Routine(
    id: 'r1',
    name: 'Rutina prueba',
    description: 'Sesión de prueba',
    focus: RoutineFocus.fullBody,
    daysOfWeek: const <RoutineDay>[RoutineDay(DateTime.monday)],
    exercises: const <RoutineExercise>[
      RoutineExercise(
        exerciseId: 'deadlift',
        name: 'Peso muerto',
        order: 0,
        sets: <RoutineSet>[
          RoutineSet(setNumber: 1, repetitions: 5, targetWeight: 80),
          RoutineSet(setNumber: 2, repetitions: 5, targetWeight: 80),
        ],
        targetMuscles: <String>['Espalda'],
        notes: null,
        equipment: 'Barra',
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
  late ProviderContainer container;
  late InMemoryRoutineRepository repository;
  late RoutineService service;
  final Routine routine = _buildRoutine();

  setUp(() {
    repository = InMemoryRoutineRepository(<Routine>[routine]);
    service = RoutineService(repository: repository);
    container = ProviderContainer(
      overrides: <Override>[
        routineRepositoryProvider.overrideWith((Ref ref) async => repository),
        routineServiceProvider.overrideWith((Ref ref) async => service),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('recordSet agrega el log y avanza a la siguiente serie', () async {
    final provider = routineSessionControllerProvider(routine.id);
    final controller = container.read(provider.notifier);
    await controller.stream.firstWhere((AsyncValue<RoutineSessionState> value) => value.hasValue);

    await controller.recordSet(
      repetitions: 5,
      weight: 82.5,
      restTaken: const Duration(seconds: 90),
    );

    final RoutineSessionState state = container.read(provider).value!;
    final List<SetLog> logs = state.logs[routine.exercises.first.exerciseId]!;
    expect(logs, hasLength(1));
    expect(logs.first.weight, 82.5);
    expect(state.currentSet?.setNumber, 2);
    expect(state.isCompleted, isFalse);
  });

  test('finishSession persiste la sesión con las notas', () async {
    final provider = routineSessionControllerProvider(routine.id);
    final controller = container.read(provider.notifier);
    await controller.stream.firstWhere((AsyncValue<RoutineSessionState> value) => value.hasValue);

    await controller.recordSet(
      repetitions: 5,
      weight: 80,
      restTaken: const Duration(seconds: 60),
    );
    await controller.recordSet(
      repetitions: 5,
      weight: 85,
      restTaken: const Duration(seconds: 75),
    );

    controller.updateNotes('Gran sesión');
    final RoutineSession? session = await controller.finishSession();

    expect(session, isNotNull);
    final List<RoutineSession> sessions = await repository
        .watchSessions(routineId: routine.id)
        .first;
    expect(sessions, isNotEmpty);
    expect(sessions.first.notes, 'Gran sesión');
    final RoutineSessionState state = container.read(provider).value!;
    expect(state.isPersisted, isTrue);
  });
}
