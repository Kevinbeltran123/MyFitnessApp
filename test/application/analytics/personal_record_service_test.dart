import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/analytics/one_rep_max_calculator.dart';
import 'package:my_fitness_tracker/application/analytics/personal_record_service.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import '../../support/fake_session_repository.dart';

void main() {
  group('PersonalRecordService', () {
    late FakeSessionRepository repository;
    late PersonalRecordService service;

    setUp(() {
      repository = FakeSessionRepository();
      service = PersonalRecordService(
        sessionRepository: repository,
        calculator: const OneRepMaxCalculator(),
      );
    });

    test('loadPersonalRecords returns highest 1RM per exercise', () async {
      repository.setSessions([
        _session(
          id: 's1',
          completedAt: DateTime(2025, 1, 10),
          exerciseId: 'squat',
          sets: [
            _set(setNumber: 1, weight: 100, reps: 5),
            _set(setNumber: 2, weight: 90, reps: 8),
          ],
        ),
        _session(
          id: 's2',
          completedAt: DateTime(2025, 1, 15),
          exerciseId: 'squat',
          sets: [_set(setNumber: 1, weight: 110, reps: 5)],
        ),
        _session(
          id: 's3',
          completedAt: DateTime(2025, 1, 20),
          exerciseId: 'bench',
          sets: [_set(setNumber: 1, weight: 80, reps: 3)],
        ),
      ]);

      final records = await service.loadPersonalRecords();
      expect(records, hasLength(2));

      final squat = records.firstWhere((r) => r.exerciseId == 'squat');
      final bench = records.firstWhere((r) => r.exerciseId == 'bench');

      expect(squat.bestWeight, 110);
      expect(squat.repetitions, 5);
      expect(squat.sessionId, 's2');
      expect(squat.oneRepMax, greaterThan(bench.oneRepMax));

      expect(bench.bestWeight, 80);
      expect(bench.repetitions, 3);
    });

    test('watchPersonalRecords emits updates when sessions change', () async {
      final List<PersonalRecord> initial = await service
          .watchPersonalRecords()
          .first;
      expect(initial, isEmpty);

      repository.setSessions([
        _session(
          id: 's1',
          completedAt: DateTime(2025, 2, 1),
          exerciseId: 'deadlift',
          sets: [_set(setNumber: 1, weight: 150, reps: 3)],
        ),
      ]);

      final List<PersonalRecord> firstUpdate = await service
          .watchPersonalRecords()
          .firstWhere((records) => records.isNotEmpty);
      expect(firstUpdate, hasLength(1));
      expect(firstUpdate.single.exerciseId, 'deadlift');
      final double firstOneRm = firstUpdate.single.oneRepMax;

      repository.setSessions([
        _session(
          id: 's1',
          completedAt: DateTime(2025, 2, 1),
          exerciseId: 'deadlift',
          sets: [_set(setNumber: 1, weight: 150, reps: 3)],
        ),
        _session(
          id: 's2',
          completedAt: DateTime(2025, 2, 5),
          exerciseId: 'deadlift',
          sets: [_set(setNumber: 1, weight: 160, reps: 3)],
        ),
      ]);

      final List<PersonalRecord> secondUpdate = await service
          .watchPersonalRecords()
          .firstWhere(
            (records) =>
                records.isNotEmpty &&
                records.first.oneRepMax > firstOneRm + 1e-6,
          );
      expect(secondUpdate.first.bestWeight, 160);
      expect(secondUpdate.first.sessionId, 's2');
    });
  });
}

RoutineSession _session({
  required String id,
  required DateTime completedAt,
  required String exerciseId,
  required List<SetLog> sets,
}) {
  return RoutineSession(
    id: id,
    routineId: 'routine-$exerciseId',
    startedAt: completedAt.subtract(const Duration(hours: 1)),
    completedAt: completedAt,
    exerciseLogs: [RoutineExerciseLog(exerciseId: exerciseId, setLogs: sets)],
    notes: null,
  );
}

SetLog _set({
  required int setNumber,
  required double weight,
  required int reps,
}) {
  return SetLog(
    setNumber: setNumber,
    repetitions: reps,
    weight: weight,
    restTaken: const Duration(seconds: 90),
  );
}
