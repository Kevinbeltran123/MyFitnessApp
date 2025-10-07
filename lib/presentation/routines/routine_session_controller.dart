import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:uuid/uuid.dart';

final routineSessionControllerProvider = StateNotifierProvider.autoDispose
    .family<RoutineSessionNotifier, AsyncValue<RoutineSessionState>, String>(
      RoutineSessionNotifier.new,
    );

class RoutineSessionState {
  RoutineSessionState({
    required this.routine,
    required this.startedAt,
    required this.exerciseIndex,
    required this.setIndex,
    required Map<String, List<SetLog>> logs,
    required this.isCompleted,
    required this.isSaving,
    required this.isPersisted,
    required this.notes,
    this.completedAt,
    this.savedSession,
    this.errorMessage,
    this.bodyMetric,
  }) : logs = Map<String, List<SetLog>>.unmodifiable(
         logs.map(
           (String key, List<SetLog> value) => MapEntry<String, List<SetLog>>(
             key,
             List<SetLog>.unmodifiable(value),
           ),
         ),
       );

  factory RoutineSessionState.initial(Routine routine) {
    final DateTime now = DateTime.now();
    return RoutineSessionState(
      routine: routine,
      startedAt: now,
      exerciseIndex: 0,
      setIndex: 0,
      logs: <String, List<SetLog>>{},
      isCompleted: routine.exercises.isEmpty,
      isSaving: false,
      isPersisted: false,
      notes: '',
      completedAt: routine.exercises.isEmpty ? now : null,
    );
  }

  final Routine routine;
  final DateTime startedAt;
  final int exerciseIndex;
  final int setIndex;
  final Map<String, List<SetLog>> logs;
  final bool isCompleted;
  final bool isSaving;
  final bool isPersisted;
  final String notes;
  final DateTime? completedAt;
  final RoutineSession? savedSession;
  final String? errorMessage;
  final BodyMetric? bodyMetric;

  int get totalSets => routine.exercises.fold(
    0,
    (int acc, RoutineExercise exercise) => acc + exercise.sets.length,
  );

  int get completedSets => logs.values.fold(
    0,
    (int acc, List<SetLog> setLogs) => acc + setLogs.length,
  );

  bool get hasAnyLog => completedSets > 0;

  bool get hasRemainingSets => !isCompleted && routine.exercises.isNotEmpty;

  RoutineExercise? get currentExercise =>
      hasRemainingSets ? routine.exercises[exerciseIndex] : null;

  RoutineSet? get currentSet =>
      hasRemainingSets ? routine.exercises[exerciseIndex].sets[setIndex] : null;

  UnmodifiableListView<SetLog> logsForExercise(String exerciseId) {
    return UnmodifiableListView<SetLog>(logs[exerciseId] ?? const <SetLog>[]);
  }

  RoutineSessionState copyWith({
    Routine? routine,
    DateTime? startedAt,
    int? exerciseIndex,
    int? setIndex,
    Map<String, List<SetLog>>? logs,
    bool? isCompleted,
    bool? isSaving,
    bool? isPersisted,
    String? notes,
    DateTime? completedAt,
    RoutineSession? savedSession,
    String? errorMessage,
    BodyMetric? bodyMetric,
  }) {
    return RoutineSessionState(
      routine: routine ?? this.routine,
      startedAt: startedAt ?? this.startedAt,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      setIndex: setIndex ?? this.setIndex,
      logs: logs ?? this.logs,
      isCompleted: isCompleted ?? this.isCompleted,
      isSaving: isSaving ?? this.isSaving,
      isPersisted: isPersisted ?? this.isPersisted,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      savedSession: savedSession ?? this.savedSession,
      errorMessage: errorMessage,
      bodyMetric: bodyMetric ?? this.bodyMetric,
    );
  }
}

class RoutineSessionNotifier
    extends StateNotifier<AsyncValue<RoutineSessionState>> {
  RoutineSessionNotifier(this.ref, this.routineId)
    : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Ref ref;
  final String routineId;
  final Uuid _uuid = const Uuid();
  RoutineService? _service;

  Future<void> _initialize() async {
    try {
      final RoutineService service = await ref.read(
        routineServiceProvider.future,
      );
      final Routine? routine = await service.getRoutine(routineId);
      if (routine == null) {
        state = AsyncValue.error(
          StateError('La rutina no se encontró'),
          StackTrace.current,
        );
        return;
      }
      _service = service;
      state = AsyncValue.data(RoutineSessionState.initial(routine));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> attachBodyMetric(BodyMetric metric) async {
    final RoutineSessionState? value = state.value;
    if (value == null) {
      return;
    }
    state = AsyncValue.data(value.copyWith(bodyMetric: metric));
  }

  Future<void> attachLatestBodyMetric() async {
    final MetricsRepository repository = ref.read(metricsRepositoryProvider);
    final BodyMetric? latest = await repository.latestMetric();
    if (latest == null) {
      return;
    }
    await attachBodyMetric(latest);
  }

  Future<void> recordSet({
    required int repetitions,
    required double weight,
    required Duration restTaken,
  }) async {
    final RoutineSessionState? value = state.value;
    if (value == null || value.isCompleted) {
      return;
    }
    final RoutineExercise? exercise = value.currentExercise;
    final RoutineSet? set = value.currentSet;
    if (exercise == null || set == null) {
      state = AsyncValue.data(
        value.copyWith(isCompleted: true, completedAt: DateTime.now()),
      );
      return;
    }

    final Map<String, List<SetLog>> updatedLogs = <String, List<SetLog>>{
      for (final MapEntry<String, List<SetLog>> entry in value.logs.entries)
        entry.key: List<SetLog>.from(entry.value),
    };
    final List<SetLog> exerciseLogs =
        updatedLogs[exercise.exerciseId] ?? <SetLog>[];
    exerciseLogs.add(
      SetLog(
        setNumber: set.setNumber,
        repetitions: repetitions,
        weight: weight,
        restTaken: restTaken.isNegative ? Duration.zero : restTaken,
      ),
    );
    updatedLogs[exercise.exerciseId] = exerciseLogs;

    int nextExerciseIndex = value.exerciseIndex;
    int nextSetIndex = value.setIndex;
    bool sessionCompleted = false;

    if (nextSetIndex + 1 < exercise.sets.length) {
      nextSetIndex += 1;
    } else {
      if (nextExerciseIndex + 1 < value.routine.exercises.length) {
        nextExerciseIndex += 1;
        nextSetIndex = 0;
      } else {
        sessionCompleted = true;
      }
    }

    state = AsyncValue.data(
      value.copyWith(
        logs: updatedLogs,
        exerciseIndex: sessionCompleted
            ? value.exerciseIndex
            : nextExerciseIndex,
        setIndex: sessionCompleted ? value.setIndex : nextSetIndex,
        isCompleted: sessionCompleted,
        completedAt: sessionCompleted ? DateTime.now() : value.completedAt,
        errorMessage: null,
      ),
    );
  }

  void updateNotes(String value) {
    state = state.whenData((RoutineSessionState current) {
      return current.copyWith(notes: value, errorMessage: null);
    });
  }

  void clearError() {
    state = state.whenData((RoutineSessionState current) {
      return current.copyWith(errorMessage: null);
    });
  }

  Future<RoutineSession?> finishSession({String? notes}) async {
    final RoutineSessionState? current = state.value;
    if (current == null) {
      return null;
    }
    final RoutineService? service = _service;
    if (service == null) {
      state = AsyncValue.data(
        current.copyWith(
          errorMessage: 'Servicio no disponible por el momento.',
        ),
      );
      return null;
    }
    if (current.isSaving) {
      return current.savedSession;
    }

    final String normalizedNotes = (notes ?? current.notes).trim();
    final DateTime completedAt = DateTime.now();
    final RoutineSession session = RoutineSession(
      id: current.savedSession?.id ?? _uuid.v4(),
      routineId: current.routine.id,
      startedAt: current.startedAt,
      completedAt: completedAt,
      exerciseLogs: current.routine.exercises
          .map(
            (RoutineExercise exercise) => RoutineExerciseLog(
              exerciseId: exercise.exerciseId,
              setLogs: List<SetLog>.from(
                current.logs[exercise.exerciseId] ?? const <SetLog>[],
              ),
            ),
          )
          .toList(growable: false),
      notes: normalizedNotes.isEmpty ? null : normalizedNotes,
    );

    state = AsyncValue.data(
      current.copyWith(
        isSaving: true,
        notes: normalizedNotes,
        errorMessage: null,
      ),
    );

    try {
      await service.logSession(session);
      final RoutineSessionState latest = state.value ?? current;
      state = AsyncValue.data(
        latest.copyWith(
          isSaving: false,
          isPersisted: true,
          isCompleted: true,
          completedAt: completedAt,
          savedSession: session,
          notes: normalizedNotes,
        ),
      );
      return session;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}
