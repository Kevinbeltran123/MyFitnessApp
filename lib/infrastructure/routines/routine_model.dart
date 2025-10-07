import 'package:isar/isar.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';

part 'routine_model.g.dart';

@Collection()
class RoutineModel {
  RoutineModel();

  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String routineId;
  late String name;
  late String description;
  @enumerated
  late RoutineFocus focus;
  List<int> daysOfWeek = <int>[];
  List<RoutineExerciseModel> exercises = <RoutineExerciseModel>[];
  late DateTime createdAt;
  late DateTime updatedAt;
  String? notes;
  bool isArchived = false;

  Routine toDomain() {
    return Routine(
      id: routineId,
      name: name,
      description: description,
      focus: focus,
      daysOfWeek: daysOfWeek.map(RoutineDay.new).toList(growable: false),
      exercises: exercises
          .map((RoutineExerciseModel model) => model.toDomain())
          .toList(growable: false),
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes,
      isArchived: isArchived,
    );
  }

  static RoutineModel fromDomain(Routine routine) {
    final model = RoutineModel()
      ..routineId = routine.id
      ..name = routine.name
      ..description = routine.description
      ..focus = routine.focus
      ..daysOfWeek = routine.daysOfWeek
          .map((RoutineDay day) => day.weekday)
          .toList()
      ..exercises = routine.exercises
          .map(RoutineExerciseModel.fromDomain)
          .toList(growable: false)
      ..createdAt = routine.createdAt
      ..updatedAt = routine.updatedAt
      ..notes = routine.notes
      ..isArchived = routine.isArchived;
    return model;
  }
}

@Embedded()
class RoutineExerciseModel {
  RoutineExerciseModel();

  late String exerciseId;
  late String name;
  late int order;
  List<String> targetMuscles = <String>[];
  List<RoutineSetModel> sets = <RoutineSetModel>[];
  String? notes;
  String? equipment;
  String? gifUrl;

  RoutineExercise toDomain() {
    return RoutineExercise(
      exerciseId: exerciseId,
      name: name,
      order: order,
      sets: sets.map((RoutineSetModel model) => model.toDomain()).toList(),
      targetMuscles: targetMuscles,
      notes: notes,
      equipment: equipment,
      gifUrl: gifUrl,
    );
  }

  static RoutineExerciseModel fromDomain(RoutineExercise exercise) {
    final model = RoutineExerciseModel()
      ..exerciseId = exercise.exerciseId
      ..name = exercise.name
      ..order = exercise.order
      ..targetMuscles = List<String>.from(exercise.targetMuscles)
      ..sets = exercise.sets
          .map(RoutineSetModel.fromDomain)
          .toList(growable: false)
      ..notes = exercise.notes
      ..equipment = exercise.equipment
      ..gifUrl = exercise.gifUrl;
    return model;
  }
}

@Embedded()
class RoutineSetModel {
  RoutineSetModel();

  late int setNumber;
  late int repetitions;
  double? targetWeight;
  int? restIntervalSeconds;

  RoutineSet toDomain() {
    return RoutineSet(
      setNumber: setNumber,
      repetitions: repetitions,
      targetWeight: targetWeight,
      restInterval: restIntervalSeconds != null
          ? Duration(seconds: restIntervalSeconds!)
          : null,
    );
  }

  static RoutineSetModel fromDomain(RoutineSet set) {
    final model = RoutineSetModel()
      ..setNumber = set.setNumber
      ..repetitions = set.repetitions
      ..targetWeight = set.targetWeight
      ..restIntervalSeconds = set.restInterval?.inSeconds;
    return model;
  }
}

@Collection()
class RoutineSessionModel {
  RoutineSessionModel();

  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String sessionId;
  late String routineId;
  late DateTime startedAt;
  late DateTime completedAt;
  List<RoutineExerciseLogModel> exerciseLogs = <RoutineExerciseLogModel>[];
  String? notes;

  RoutineSession toDomain() {
    return RoutineSession(
      id: sessionId,
      routineId: routineId,
      startedAt: startedAt,
      completedAt: completedAt,
      exerciseLogs: exerciseLogs
          .map((RoutineExerciseLogModel model) => model.toDomain())
          .toList(growable: false),
      notes: notes,
    );
  }

  static RoutineSessionModel fromDomain(RoutineSession session) {
    final model = RoutineSessionModel()
      ..sessionId = session.id
      ..routineId = session.routineId
      ..startedAt = session.startedAt
      ..completedAt = session.completedAt
      ..exerciseLogs = session.exerciseLogs
          .map(RoutineExerciseLogModel.fromDomain)
          .toList(growable: false)
      ..notes = session.notes;
    return model;
  }
}

@Embedded()
class RoutineExerciseLogModel {
  RoutineExerciseLogModel();

  late String exerciseId;
  List<SetLogModel> setLogs = <SetLogModel>[];

  RoutineExerciseLog toDomain() {
    return RoutineExerciseLog(
      exerciseId: exerciseId,
      setLogs: setLogs
          .map((SetLogModel model) => model.toDomain())
          .toList(growable: false),
    );
  }

  static RoutineExerciseLogModel fromDomain(RoutineExerciseLog log) {
    final model = RoutineExerciseLogModel()
      ..exerciseId = log.exerciseId
      ..setLogs = log.setLogs
          .map((SetLog entry) => SetLogModel.fromDomain(entry))
          .toList(growable: false);
    return model;
  }
}

@Embedded()
class SetLogModel {
  SetLogModel();

  late int setNumber;
  late int repetitions;
  late double weight;
  late int restTakenSeconds;

  SetLog toDomain() {
    return SetLog(
      setNumber: setNumber,
      repetitions: repetitions,
      weight: weight,
      restTaken: Duration(seconds: restTakenSeconds),
    );
  }

  static SetLogModel fromDomain(SetLog log) {
    final model = SetLogModel()
      ..setNumber = log.setNumber
      ..repetitions = log.repetitions
      ..weight = log.weight
      ..restTakenSeconds = log.restTaken.inSeconds;
    return model;
  }
}
