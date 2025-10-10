import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
// ignore: unused_import
import 'package:isar_flutter_libs/isar_flutter_libs.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/infrastructure/metrics/metrics_repository_isar.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_repository_isar.dart';
import 'package:my_fitness_tracker/infrastructure/sessions/session_repository_isar.dart';

import '../support/isar_test_utils.dart';

Future<Isar> _openIsar(String directory, String name) {
  return TestIsarFactory.open(
    directory: directory,
    name: name,
    schemas: moduleOneSchemas,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseTestHelper dbHelper;

  setUpAll(() async {
    await TestIsarFactory.ensureInitialized();
  });

  setUp(() async {
    dbHelper = await DatabaseTestHelper.setUp('module_1_2_db');
  });

  tearDown(() async {
    await dbHelper.tearDown();
  });

  test('routine data persists with exercises and schedule after restart',
      () async {
    const String dbName = 'routine_persist';
    final Isar isar = await _openIsar(dbHelper.path, dbName);
    final RoutineRepositoryIsar repo = RoutineRepositoryIsar(isar);

    final Routine routine = MockDataGenerator.routine(id: 'strength');
    await repo.saveRoutine(routine);
    await isar.close();

    final Isar reopened = await _openIsar(dbHelper.path, dbName);
    addTearDown(() async {
      if (reopened.isOpen) {
        await reopened.close();
      }
    });
    final RoutineRepositoryIsar repoReopened = RoutineRepositoryIsar(reopened);

    final Routine? fetched = await repoReopened.getById(routine.id);
    expect(fetched, isNotNull);
    expect(
      fetched!.daysOfWeek.map((RoutineDay day) => day.weekday).toSet(),
      equals(<int>{DateTime.monday, DateTime.friday}),
    );
    expect(fetched.exercises.length, 2);
    expect(fetched.exercises.first.sets.first.targetWeight, 80);
    expect(fetched.notes, routine.notes);
  });

  test(
      'body metrics and metabolic profile persist between Isar reopen cycles',
      () async {
    const String dbName = 'metrics_persist';
    final Isar isar = await _openIsar(dbHelper.path, dbName);
    final MetricsRepositoryIsar repo = MetricsRepositoryIsar(isar);

    final BodyMetric metricOne = MockDataGenerator.bodyMetric(
      id: 'metric-1',
      recordedAt: DateTime(2024, 3, 1, 7),
      weightKg: 82.4,
      bodyFat: 20.1,
      muscleMass: 35.0,
      measurements: const <String, double>{'cintura': 88.3},
    );
    final BodyMetric metricTwo = MockDataGenerator.bodyMetric(
      id: 'metric-2',
      recordedAt: DateTime(2024, 3, 8, 7),
      weightKg: 81.6,
      bodyFat: 19.8,
      muscleMass: 35.2,
      measurements: const <String, double>{
        'cintura': 87.5,
        'pecho': 101.2,
      },
    );
    final MetabolicProfile profile = MockDataGenerator.metabolicProfile(
      id: 'profile-main',
      heightCm: 178,
      weightKg: 81.6,
      age: 30,
      sex: BiologicalSex.male,
      activityMultiplier: 1.45,
      updatedAt: DateTime(2024, 3, 8, 9),
    );

    await repo.upsertMetric(metricOne);
    await repo.upsertMetric(metricTwo);
    await repo.saveMetabolicProfile(profile);
    await isar.close();

    final Isar reopened = await _openIsar(dbHelper.path, dbName);
    addTearDown(() async {
      if (reopened.isOpen) {
        await reopened.close();
      }
    });
    final MetricsRepositoryIsar repoReopened = MetricsRepositoryIsar(reopened);

    final List<BodyMetric> persistedMetrics =
        await repoReopened.watchMetrics().first;
    expect(persistedMetrics.length, 2);
    expect(persistedMetrics.first.id, 'metric-2'); // Sorted desc by recordedAt
    expect(persistedMetrics.last.measurements['cintura'], 88.3);

    final MetabolicProfile? persistedProfile =
        await repoReopened.loadMetabolicProfile();
    expect(persistedProfile, isNotNull);
    expect(persistedProfile!.heightCm, 178);
    expect(persistedProfile.activityMultiplier, closeTo(1.45, 0.0001));
  });

  test('workout sessions persist with detailed logs after restart', () async {
    const String dbName = 'session_persist';
    final Isar isar = await _openIsar(dbHelper.path, dbName);
    final SessionRepositoryIsar repo = SessionRepositoryIsar(isar);

    final RoutineSession session = MockDataGenerator.routineSession(
      id: 'session-1',
      routineId: 'routine-strength',
    );
    await repo.saveSession(session);
    await isar.close();

    final Isar reopened = await _openIsar(dbHelper.path, dbName);
    addTearDown(() async {
      if (reopened.isOpen) {
        await reopened.close();
      }
    });
    final SessionRepositoryIsar repoReopened = SessionRepositoryIsar(reopened);

    final List<RoutineSession> sessions =
        await repoReopened.getAllSessions();
    expect(sessions, hasLength(1));
    final RoutineSession persisted = sessions.first;
    expect(persisted.notes, contains('strong'));
    expect(persisted.exerciseLogs.first.setLogs.length, 2);
    expect(persisted.exerciseLogs.first.setLogs.first.weight, 80);

    final RoutineSession? latest = await repoReopened.getLatestSession();
    expect(latest?.id, session.id);
  });

  test(
      'archived routines remain archived after restart and excluded from active watch',
      () async {
    const String dbName = 'archive_persist';
    final Isar isar = await _openIsar(dbHelper.path, dbName);
    final RoutineRepositoryIsar repo = RoutineRepositoryIsar(isar);

    final Routine routineA = MockDataGenerator.routine(id: 'archive-a');
    final Routine routineB = MockDataGenerator.routine(id: 'archive-b');
    await repo.saveRoutine(routineA);
    await repo.saveRoutine(routineB);
    await repo.deleteRoutine(routineA.id); // Archive (soft delete)
    await repo.deleteRoutine(routineB.id); // Archive
    await isar.close();

    final Isar reopened = await _openIsar(dbHelper.path, dbName);
    addTearDown(() async {
      if (reopened.isOpen) {
        await reopened.close();
      }
    });
    final RoutineRepositoryIsar repoReopened = RoutineRepositoryIsar(reopened);

    final List<Routine> active =
        await repoReopened.watchAll(includeArchived: false).first;
    expect(active, isEmpty);

    final List<Routine> archived =
        await repoReopened.watchAll(includeArchived: true).first;
    expect(archived.map((Routine r) => r.id).toSet(),
        equals(<String>{'archive-a', 'archive-b'}));
    expect(archived.every((Routine r) => r.isArchived), isTrue);

    final Routine restored = archived.first.copyWith(isArchived: false);
    await repoReopened.saveRoutine(restored);
    final List<Routine> restoredList =
        await repoReopened.watchAll(includeArchived: false).first;
    expect(restoredList.any((Routine r) => r.id == restored.id), isTrue);
  });
}
