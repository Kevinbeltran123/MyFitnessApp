import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';

import '../../support/in_memory_routine_repository.dart';

Routine _routine(String id) {
  return Routine(
    id: id,
    name: 'Rutina $id',
    description: 'Demo',
    focus: RoutineFocus.fullBody,
    daysOfWeek: const <RoutineDay>[RoutineDay(DateTime.monday)],
    exercises: const <RoutineExercise>[],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    notes: null,
    isArchived: false,
  );
}

RoutineSession _session(
  String id,
  String routineId,
  DateTime startedAt,
  DateTime completedAt,
) {
  return RoutineSession(
    id: id,
    routineId: routineId,
    startedAt: startedAt,
    completedAt: completedAt,
    exerciseLogs: const <RoutineExerciseLog>[],
    notes: null,
  );
}

Future<void> _pumpEventQueue() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'routineLastUsedProvider exposes latest completion per routine',
    () async {
      final InMemoryRoutineRepository repository = InMemoryRoutineRepository();

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          routineRepositoryProvider.overrideWith((Ref ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final ProviderSubscription<AsyncValue<Map<String, DateTime>>> sub =
          container.listen(routineLastUsedProvider, (_, __) {});
      addTearDown(sub.close);

      await repository.saveRoutine(_routine('routine-a'));
      await repository.saveRoutine(_routine('routine-b'));

      await _pumpEventQueue();
      expect(sub.read().valueOrNull, isEmpty);

      final DateTime firstCompleted = DateTime(2024, 5, 10, 8, 0);
      await repository.upsertSession(
        _session('session-1', 'routine-a', firstCompleted, firstCompleted),
      );
      await _pumpEventQueue();
      expect(sub.read().value?['routine-a'], firstCompleted);

      final DateTime newerCompleted = DateTime(2024, 5, 12, 7, 30);
      await repository.upsertSession(
        _session('session-2', 'routine-a', newerCompleted, newerCompleted),
      );
      await _pumpEventQueue();
      expect(sub.read().value?['routine-a'], newerCompleted);

      final DateTime otherRoutineCompleted = DateTime(2024, 5, 11, 9, 15);
      await repository.upsertSession(
        _session(
          'session-3',
          'routine-b',
          otherRoutineCompleted,
          otherRoutineCompleted,
        ),
      );
      await _pumpEventQueue();
      final Map<String, DateTime>? values = sub.read().value;
      expect(values?['routine-a'], newerCompleted);
      expect(values?['routine-b'], otherRoutineCompleted);
    },
  );
}
