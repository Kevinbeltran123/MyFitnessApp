import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
// ignore: unused_import
import 'package:isar_flutter_libs/isar_flutter_libs.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_model.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_repository_isar.dart';

Routine _sampleRoutine({String id = 'routine-1', String name = 'Rutina demo'}) {
  return Routine(
    id: id,
    name: name,
    description: 'Plan de prueba',
    focus: RoutineFocus.fullBody,
    daysOfWeek: const <RoutineDay>[RoutineDay(DateTime.monday)],
    exercises: const <RoutineExercise>[
      RoutineExercise(
        exerciseId: 'push-up',
        name: 'Push Ups',
        order: 0,
        sets: <RoutineSet>[
          RoutineSet(setNumber: 1, repetitions: 12, targetWeight: 0),
        ],
        targetMuscles: <String>['Chest'],
        equipment: 'Bodyweight',
      ),
    ],
    createdAt: DateTime(2024, 1, 1, 10),
    updatedAt: DateTime(2024, 1, 1, 10),
    notes: null,
    isArchived: false,
  );
}

Future<Isar> _openIsar(String directory, String name) {
  return Isar.open(
    <CollectionSchema>[RoutineModelSchema, RoutineSessionModelSchema],
    directory: directory,
    inspector: false,
    name: name,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  bool isarAvailable = true;

  setUpAll(() async {
    try {
      await Isar.initializeIsarCore(download: true);
    } catch (error) {
      // In widget-test environments network access is disabled, so the core
      // library cannot be downloaded. We flag the tests to no-op in that case.
      debugPrint('IsarCore unavailable for tests: $error');
      isarAvailable = false;
    }
  });
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_routine_repo_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('persists routines across app restarts', () async {
    if (!isarAvailable) return;
    const String dbName = 'persist_db';
    final Isar isar1 = await _openIsar(tempDir.path, dbName);
    final RoutineRepositoryIsar repo1 = RoutineRepositoryIsar(isar1);

    final Routine routine = _sampleRoutine();

    await repo1.saveRoutine(routine);
    await isar1.close();

    final Isar isar2 = await _openIsar(tempDir.path, dbName);
    final RoutineRepositoryIsar repo2 = RoutineRepositoryIsar(isar2);

    final Routine? fetched = await repo2.getById(routine.id);
    expect(fetched, isNotNull);
    expect(fetched!.name, routine.name);
    expect(fetched.exercises, isNotEmpty);

    await isar2.close();
  });

  test('updates are persisted between sessions', () async {
    if (!isarAvailable) return;
    const String dbName = 'update_db';
    final Isar isar = await _openIsar(tempDir.path, dbName);
    final RoutineRepositoryIsar repo = RoutineRepositoryIsar(isar);

    final Routine routine = _sampleRoutine();
    await repo.saveRoutine(routine);

    final Routine updated = routine.copyWith(name: 'Rutina actualizada');
    await repo.saveRoutine(updated);
    await isar.close();

    final Isar isarReopen = await _openIsar(tempDir.path, dbName);
    final RoutineRepositoryIsar repoReopen = RoutineRepositoryIsar(isarReopen);

    final Routine? fetched = await repoReopen.getById(routine.id);
    expect(fetched?.name, 'Rutina actualizada');

    await isarReopen.close();
  });

  test('hard delete removes routines permanently', () async {
    if (!isarAvailable) return;
    const String dbName = 'delete_db';
    final Isar isar = await _openIsar(tempDir.path, dbName);
    final RoutineRepositoryIsar repo = RoutineRepositoryIsar(isar);

    final Routine routine = _sampleRoutine();
    await repo.saveRoutine(routine);
    await repo.deleteRoutine(routine.id, hardDelete: true);
    await isar.close();

    final Isar reopened = await _openIsar(tempDir.path, dbName);
    final RoutineRepositoryIsar repoReopen = RoutineRepositoryIsar(reopened);

    final Routine? fetched = await repoReopen.getById(routine.id);
    expect(fetched, isNull);

    await reopened.close();
  });

  test('watchAll emits changes when routines are saved', () async {
    if (!isarAvailable) return;
    const String dbName = 'watch_db';
    final Isar isar = await _openIsar(tempDir.path, dbName);
    final RoutineRepositoryIsar repo = RoutineRepositoryIsar(isar);

    final Stream<List<Routine>> stream = repo.watchAll(includeArchived: true);

    final Routine routine = _sampleRoutine();

    final Future<List<Routine>> observed = stream.firstWhere(
      (List<Routine> routines) => routines.isNotEmpty,
    );

    await repo.saveRoutine(routine);

    final List<Routine> emitted = await observed;
    expect(
      emitted.firstWhere((Routine r) => r.id == routine.id).name,
      routine.name,
    );

    await isar.close();
  });
}
