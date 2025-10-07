// Domain entities describing a workout routine template and related concepts.
//
// These models remain framework-agnostic. Persistence-specific models live
// under `lib/infrastructure` and convert to/from these entities.
import 'package:collection/collection.dart';

/// Identifies the muscle focus or context for a routine. This can back UI
/// filters and analytics without being tied to a specific API response.
enum RoutineFocus {
  fullBody,
  upperBody,
  lowerBody,
  push,
  pull,
  core,
  mobility,
  custom,
}

/// Represents a routine definition containing ordered exercises.
class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.focus,
    required this.daysOfWeek,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final String description;
  final RoutineFocus focus;
  final List<RoutineDay> daysOfWeek;
  final List<RoutineExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final bool isArchived;

  Routine copyWith({
    String? id,
    String? name,
    String? description,
    RoutineFocus? focus,
    List<RoutineDay>? daysOfWeek,
    List<RoutineExercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    bool? isArchived,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      focus: focus ?? this.focus,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  bool get hasExercises => exercises.isNotEmpty;
  bool get hasActiveDays => daysOfWeek.isNotEmpty;

  /// Returns true if the routine is scheduled for the given [day].
  bool isScheduledFor(DateTime day) {
    final weekday = RoutineDay.fromDateTime(day);
    return daysOfWeek.contains(weekday);
  }
}

/// Represents an ordered exercise inside a routine with prescribed work.
class RoutineExercise {
  const RoutineExercise({
    required this.exerciseId,
    required this.name,
    required this.order,
    required this.sets,
    required this.targetMuscles,
    this.notes,
    this.equipment,
    this.gifUrl,
  });

  final String exerciseId;
  final String name;
  final int order;
  final List<RoutineSet> sets;
  final List<String> targetMuscles;
  final String? notes;
  final String? equipment;
  final String? gifUrl;

  RoutineExercise copyWith({
    String? exerciseId,
    String? name,
    int? order,
    List<RoutineSet>? sets,
    List<String>? targetMuscles,
    String? notes,
    String? equipment,
    String? gifUrl,
  }) {
    return RoutineExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      notes: notes ?? this.notes,
      equipment: equipment ?? this.equipment,
      gifUrl: gifUrl ?? this.gifUrl,
    );
  }

  int get totalVolume => sets.map((RoutineSet s) => s.estimatedVolume).sum;
}

/// Single set prescription with reps, optional target weight and rest.
class RoutineSet {
  const RoutineSet({
    required this.setNumber,
    required this.repetitions,
    this.targetWeight,
    this.restInterval,
  });

  final int setNumber;
  final int repetitions;
  final double? targetWeight;
  final Duration? restInterval;

  int get estimatedVolume => (targetWeight ?? 0).round() * repetitions;
}

/// Identifies days the routine is planned for.
class RoutineDay {
  const RoutineDay(this.weekday);

  final int weekday; // 1 = Monday, aligns with DateTime.monday constant.

  static const List<String> shortLabels = <String>[
    'L',
    'M',
    'X',
    'J',
    'V',
    'S',
    'D',
  ];

  String get shortLabel => shortLabels[(weekday - 1) % 7];

  static RoutineDay fromDateTime(DateTime date) => RoutineDay(date.weekday);
}

/// Historical log for completed routine session (used later for analytics).
class RoutineSession {
  const RoutineSession({
    required this.id,
    required this.routineId,
    required this.startedAt,
    required this.completedAt,
    required this.exerciseLogs,
    this.notes,
  });

  final String id;
  final String routineId;
  final DateTime startedAt;
  final DateTime completedAt;
  final List<RoutineExerciseLog> exerciseLogs;
  final String? notes;
}

class RoutineExerciseLog {
  const RoutineExerciseLog({required this.exerciseId, required this.setLogs});

  final String exerciseId;
  final List<SetLog> setLogs;
}

class SetLog {
  const SetLog({
    required this.setNumber,
    required this.repetitions,
    required this.weight,
    required this.restTaken,
  });

  final int setNumber;
  final int repetitions;
  final double weight;
  final Duration restTaken;
}
