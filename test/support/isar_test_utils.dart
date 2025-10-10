import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/infrastructure/metrics/metrics_model.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_model.dart';

/// Factory that provides configured Isar instances for tests without relying on
/// network downloads during execution.
class TestIsarFactory {
  static bool _initialized = false;

  /// Ensure IsarCore is available by looking up the local flutter libs
  /// directory and loading the bundled binaries.
  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    final Map<Abi, String> libraries = await _resolveIsarLibraries();
    try {
      await Isar.initializeIsarCore(libraries: libraries);
    } on Object {
      await Isar.initializeIsarCore(download: true);
    }
    _initialized = true;
  }

  /// Opens an Isar instance using the provided schemas in a temporary
  /// directory. The caller is responsible for closing the instance.
  static Future<Isar> open({
    required String directory,
    String name = Isar.defaultName,
    required List<CollectionSchema> schemas,
  }) async {
    await ensureInitialized();
    return Isar.open(
      schemas,
      directory: directory,
      name: name,
      inspector: false,
    );
  }

  static Future<Map<Abi, String>> _resolveIsarLibraries() async {
    final Directory? packageRoot = await _findPackageRoot('isar_flutter_libs');
    if (packageRoot == null) {
      return const <Abi, String>{};
    }

    final Map<Abi, String> libraries = <Abi, String>{};
    if (Platform.isMacOS) {
      final String dylibPath =
          '${packageRoot.path}${Platform.pathSeparator}macos${Platform.pathSeparator}libisar.dylib';
      if (File(dylibPath).existsSync()) {
        libraries[Abi.macosArm64] = dylibPath;
        libraries[Abi.macosX64] = dylibPath;
      }
    } else if (Platform.isLinux) {
      final String soPath =
          '${packageRoot.path}${Platform.pathSeparator}linux${Platform.pathSeparator}libisar.so';
      if (File(soPath).existsSync()) {
        libraries[Abi.linuxX64] = soPath;
      }
    } else if (Platform.isWindows) {
      final String dllPath =
          '${packageRoot.path}${Platform.pathSeparator}windows${Platform.pathSeparator}isar.dll';
      if (File(dllPath).existsSync()) {
        libraries[Abi.windowsX64] = dllPath;
        libraries[Abi.windowsArm64] = dllPath;
      }
    }
    return libraries;
  }

  static Future<Directory?> _findPackageRoot(String packageName) async {
    final File configFile = File('.dart_tool/package_config.json');
    if (!await configFile.exists()) {
      return null;
    }

    final Map<String, dynamic> config =
        jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
    final List<dynamic> packages = config['packages'] as List<dynamic>;
    for (final dynamic package in packages) {
      final Map<String, dynamic> entry = package as Map<String, dynamic>;
      if (entry['name'] == packageName) {
        final String rootUriString = entry['rootUri'] as String;
        final Uri rootUri = Uri.parse(rootUriString);
        final Uri resolved =
            rootUri.isAbsolute ? rootUri : configFile.uri.resolveUri(rootUri);
        return Directory.fromUri(resolved);
      }
    }
    return null;
  }
}

/// Utility helpers for dealing with temporary database directories inside
/// tests.
class DatabaseTestHelper {
  DatabaseTestHelper(this._tempDir);

  final Directory _tempDir;

  static Future<DatabaseTestHelper> setUp(String prefix) async {
    final Directory dir = await Directory.systemTemp.createTemp(prefix);
    return DatabaseTestHelper(dir);
  }

  String get path => _tempDir.path;

  Future<void> tearDown() async {
    if (await _tempDir.exists()) {
      await _tempDir.delete(recursive: true);
    }
  }
}

/// Generates consistent mock domain entities for integration tests.
class MockDataGenerator {
  const MockDataGenerator._();

  static Routine routine({
    required String id,
    RoutineFocus focus = RoutineFocus.fullBody,
    DateTime? createdAt,
  }) {
    final DateTime timestamp = createdAt ?? DateTime(2024, 1, 5, 8);
    return Routine(
      id: id,
      name: 'Routine $id',
      description: 'Sample routine $id for integration tests',
      focus: focus,
      daysOfWeek: const <RoutineDay>[
        RoutineDay(DateTime.monday),
        RoutineDay(DateTime.friday),
      ],
      exercises: const <RoutineExercise>[
        RoutineExercise(
          exerciseId: 'squat',
          name: 'Back Squat',
          order: 0,
          sets: <RoutineSet>[
            RoutineSet(setNumber: 1, repetitions: 5, targetWeight: 80),
            RoutineSet(setNumber: 2, repetitions: 5, targetWeight: 85),
          ],
          targetMuscles: <String>['Legs', 'Core'],
          notes: 'Keep chest up',
        ),
        RoutineExercise(
          exerciseId: 'bench',
          name: 'Bench Press',
          order: 1,
          sets: <RoutineSet>[
            RoutineSet(setNumber: 1, repetitions: 5, targetWeight: 70),
            RoutineSet(setNumber: 2, repetitions: 5, targetWeight: 72.5),
          ],
          targetMuscles: <String>['Chest', 'Triceps'],
          notes: 'Pause 1s on chest',
        ),
      ],
      createdAt: timestamp,
      updatedAt: timestamp,
      notes: 'Initial strength block',
      isArchived: false,
    );
  }

  static BodyMetric bodyMetric({
    required String id,
    required DateTime recordedAt,
    required double weightKg,
    Map<String, double> measurements = const <String, double>{},
    double? bodyFat,
    double? muscleMass,
  }) {
    return BodyMetric(
      id: id,
      recordedAt: recordedAt,
      weightKg: weightKg,
      bodyFatPercentage: bodyFat,
      muscleMassKg: muscleMass,
      notes: 'Entry $id',
      measurements: measurements,
    );
  }

  static MetabolicProfile metabolicProfile({
    required String id,
    required double heightCm,
    required double weightKg,
    required int age,
    BiologicalSex sex = BiologicalSex.male,
    double activityMultiplier = 1.35,
    DateTime? updatedAt,
  }) {
    return MetabolicProfile(
      id: id,
      updatedAt: updatedAt ?? DateTime(2024, 3, 8, 9),
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      sex: sex,
      activityMultiplier: activityMultiplier,
    );
  }

  static RoutineSession routineSession({
    required String id,
    required String routineId,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    final DateTime start = startedAt ?? DateTime(2024, 2, 15, 7);
    final DateTime end = completedAt ?? start.add(const Duration(minutes: 65));
    return RoutineSession(
      id: id,
      routineId: routineId,
      startedAt: start,
      completedAt: end,
      exerciseLogs: const <RoutineExerciseLog>[
        RoutineExerciseLog(
          exerciseId: 'squat',
          setLogs: <SetLog>[
            SetLog(
              setNumber: 1,
              repetitions: 5,
              weight: 80,
              restTaken: Duration(seconds: 120),
            ),
            SetLog(
              setNumber: 2,
              repetitions: 5,
              weight: 85,
              restTaken: Duration(seconds: 150),
            ),
          ],
        ),
        RoutineExerciseLog(
          exerciseId: 'bench',
          setLogs: <SetLog>[
            SetLog(
              setNumber: 1,
              repetitions: 5,
              weight: 70,
              restTaken: Duration(seconds: 90),
            ),
          ],
        ),
      ],
      notes: 'Felt strong, repeat weight next session.',
    );
  }
}

/// Convenience list of schemas touched by Module 1 persistence tests.
final List<CollectionSchema> moduleOneSchemas = <CollectionSchema>[
  RoutineModelSchema,
  RoutineSessionModelSchema,
  BodyMetricModelSchema,
  MetabolicProfileModelSchema,
];
