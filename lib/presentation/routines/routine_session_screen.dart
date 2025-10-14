import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/analytics/personal_record_service.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/timers/rest_timer_entities.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/rest_timer_controller.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_session_controller.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';

class RoutineSessionScreen extends ConsumerStatefulWidget {
  const RoutineSessionScreen({super.key, required this.routineId});

  final String routineId;

  @override
  ConsumerState<RoutineSessionScreen> createState() =>
      _RoutineSessionScreenState();
}

class _RoutineSessionScreenState extends ConsumerState<RoutineSessionScreen> {
  Timer? _sessionTicker;
  DateTime? _sessionStartedAt;
  Duration _sessionElapsed = Duration.zero;

  final TextEditingController _notesController = TextEditingController();
  bool _notesInitialized = false;
  PersonalRecordService? _personalRecordService;
  List<PersonalRecord> _baselinePersonalRecords = const <PersonalRecord>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadInitialPersonalRecords();
    });
  }

  @override
  void dispose() {
    _sessionTicker?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _ensureSessionTimer(DateTime startedAt) {
    if (_sessionStartedAt == startedAt) {
      return;
    }
    _sessionStartedAt = startedAt;
    _sessionElapsed = DateTime.now().difference(startedAt);
    _sessionTicker?.cancel();
    _sessionTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _sessionStartedAt == null) {
        return;
      }
      setState(() {
        _sessionElapsed = DateTime.now().difference(_sessionStartedAt!);
      });
    });
  }

  Duration _defaultRestFor(RoutineSet? set) {
    if (set?.restInterval != null) {
      return set!.restInterval!;
    }
    return const Duration(seconds: 90);
  }

  RestTimerRequest? _restRequestForState(RoutineSessionState state) {
    final RoutineExercise? exercise = state.currentExercise;
    final RoutineSet? set = state.currentSet;
    if (exercise == null || set == null) {
      return null;
    }
    return RestTimerRequest(
      routineId: state.routine.id,
      exerciseId: exercise.exerciseId,
      setIndex: set.setNumber,
      config: RestTimerConfig(
        target: _defaultRestFor(set),
        enableNotification: true,
        enableVibration: true,
      ),
      sessionId: state.savedSession?.id,
    );
  }

  Future<void> _cancelRestTimer(RestTimerRequest? request) async {
    if (request == null) {
      return;
    }
    await ref.read(restTimerControllerProvider(request).notifier).cancel();
  }

  Future<void> _loadInitialPersonalRecords() async {
    try {
      final PersonalRecordService service = await ref.read(
        personalRecordServiceProvider.future,
      );
      final List<PersonalRecord> records = await service.loadPersonalRecords();
      if (!mounted) {
        return;
      }
      _personalRecordService = service;
      _baselinePersonalRecords = records;
    } catch (_) {
      // Ignore errors silently; the screen will continue without PR feedback.
    }
  }

  Future<void> _checkForNewPersonalRecords(RoutineSession session) async {
    try {
      final PersonalRecordService service =
          _personalRecordService ??
          await ref.read(personalRecordServiceProvider.future);
      final List<PersonalRecord> latest = await service.loadPersonalRecords();
      if (!mounted) {
        return;
      }

      final Map<String, PersonalRecord> previous = <String, PersonalRecord>{
        for (final PersonalRecord record in _baselinePersonalRecords)
          record.exerciseId: record,
      };
      final Set<String> sessionExerciseIds = session.exerciseLogs
          .map((RoutineExerciseLog log) => log.exerciseId)
          .toSet();

      final List<PersonalRecord> newRecords = <PersonalRecord>[];
      for (final PersonalRecord record in latest) {
        if (!sessionExerciseIds.contains(record.exerciseId)) {
          continue;
        }
        final PersonalRecord? before = previous[record.exerciseId];
        if (before == null || record.oneRepMax > before.oneRepMax + 1e-6) {
          newRecords.add(record);
        }
      }

      if (newRecords.isNotEmpty) {
        final PersonalRecord highlight = newRecords.first;
        final String name = highlight.exerciseName?.trim().isNotEmpty == true
            ? highlight.exerciseName!.trim()
            : highlight.exerciseId;
        final String message = newRecords.length == 1
            ? '¡Nuevo PR en $name! 1RM estimado: '
                  '${highlight.oneRepMax.toStringAsFixed(1)} kg'
            : '¡Nuevo PR en ${newRecords.length} ejercicios! '
                  'Último: $name '
                  '(${highlight.oneRepMax.toStringAsFixed(1)} kg)';

        AppSnackBar.showSuccess(context, message);
      }

      _baselinePersonalRecords = latest;
      _personalRecordService = service;
    } catch (_) {
      // Ignore failures silently; notifications are a best-effort enhancement.
    }
  }

  Future<void> _logCurrentSet(RoutineSessionState state) async {
    final RoutineExercise? exercise = state.currentExercise;
    final RoutineSet? routineSet = state.currentSet;
    if (exercise == null || routineSet == null) {
      return;
    }

    final Duration suggestedRest = _defaultRestFor(routineSet);

    final _LogSetResult? result = await showModalBottomSheet<_LogSetResult>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _LogSetSheet(
          exercise: exercise,
          routineSet: routineSet,
          initialRest: suggestedRest,
        );
      },
    );

    if (result == null) {
      return;
    }

    final RestTimerRequest outgoingRequest = RestTimerRequest(
      routineId: state.routine.id,
      exerciseId: exercise.exerciseId,
      setIndex: routineSet.setNumber,
      config: RestTimerConfig(target: suggestedRest),
      sessionId: state.savedSession?.id,
    );

    final sessionNotifier = ref.read(
      routineSessionControllerProvider(widget.routineId).notifier,
    );

    await sessionNotifier.recordSet(
      repetitions: result.repetitions,
      weight: result.weight,
      restTaken: Duration(seconds: result.restSeconds),
    );

    // Cancel any running timer for the set just finalised.
    await _cancelRestTimer(outgoingRequest);

    final RoutineSessionState? updated = ref
        .read(routineSessionControllerProvider(widget.routineId))
        .value;
    if (!context.mounted || updated == null) {
      return;
    }

    if (updated.isCompleted) {
      await _showCompletionSheet(updated);
      return;
    }

    final RoutineExercise? nextExercise = updated.currentExercise;
    final RoutineSet? nextSet = updated.currentSet;
    if (nextExercise == null || nextSet == null) {
      return;
    }

    final RestTimerRequest nextRequest = RestTimerRequest(
      routineId: updated.routine.id,
      exerciseId: nextExercise.exerciseId,
      setIndex: nextSet.setNumber,
      config: RestTimerConfig(target: _defaultRestFor(nextSet)),
      sessionId: updated.savedSession?.id,
    );

    await ref
        .read(restTimerControllerProvider(nextRequest).notifier)
        .start(config: nextRequest.config);
  }

  Future<void> _finishSession(RoutineSessionState state) async {
    final RoutineSessionNotifier controller = ref.read(
      routineSessionControllerProvider(widget.routineId).notifier,
    );
    final RoutineSession? session = await controller.finishSession();
    if (!mounted) {
      return;
    }
    if (session != null) {
      await _checkForNewPersonalRecords(session);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(session);
    }
  }

  Future<void> _showCompletionSheet(RoutineSessionState state) async {
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final int totalSets = state.totalSets;
        final int completedSets = state.completedSets;
        final double volume = _calculateTotalVolume(state);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '¡Sesión completada! 🎉',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text('Series completadas: $completedSets de $totalSets'),
              Text(
                'Volumen total estimado: ${volume.toStringAsFixed(1)} kg·reps',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Continuar'),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateTotalVolume(RoutineSessionState state) {
    return state.logs.entries.fold(0.0, (
      double acc,
      MapEntry<String, List<SetLog>> entry,
    ) {
      final double exerciseVolume = entry.value.fold(0.0, (
        double sum,
        SetLog log,
      ) {
        return sum + (log.weight * log.repetitions);
      });
      return acc + exerciseVolume;
    });
  }

  Future<bool> _confirmExit(RoutineSessionState? state) async {
    if (state == null || !state.hasAnyLog || state.isPersisted) {
      return true;
    }
    final bool? shouldLeave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Salir del entrenamiento?'),
          content: const Text(
            'Perderás el progreso no guardado de esta sesión.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RoutineSessionState> sessionAsync = ref.watch(
      routineSessionControllerProvider(widget.routineId),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldExit = await _confirmExit(sessionAsync.valueOrNull);
        if (!context.mounted) return;
        if (shouldExit) {
          Navigator.of(context).pop(result);
        }
      },
      child: sessionAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (Object error, StackTrace stackTrace) => Scaffold(
          appBar: AppBar(title: const Text('Modo entrenamiento')),
          body: Center(child: Text(error.toString())),
        ),
        data: (RoutineSessionState state) {
          if (!_notesInitialized || _notesController.text != state.notes) {
            _notesController.text = state.notes;
            _notesInitialized = true;
          }
          _ensureSessionTimer(state.startedAt);

          final RoutineExercise? exercise = state.currentExercise;
          final RoutineSet? routineSet = state.currentSet;

          final RestTimerRequest? restRequest = _restRequestForState(state);
          final RestTimerSnapshot? restSnapshot = restRequest == null
              ? null
              : ref.watch(restTimerControllerProvider(restRequest));
          final restNotifier = restRequest == null
              ? null
              : ref.read(restTimerControllerProvider(restRequest).notifier);
          final RestTimerStatus restStatus =
              restSnapshot?.status ?? RestTimerStatus.idle;
          final Duration restElapsed = restSnapshot?.elapsed ?? Duration.zero;
          final Duration restTarget =
              restSnapshot?.config.target ??
              restRequest?.config.target ??
              const Duration(seconds: 90);

          final int totalSets = max(state.totalSets, 1);
          final int completedSets = state.completedSets;
          final double progress = completedSets / totalSets;
          final Duration recommendedRest = _defaultRestFor(
            routineSet ?? exercise?.sets.first,
          );

          Future<void> Function()? restPrimaryAction;
          IconData restPrimaryIcon = Icons.play_circle_outline;
          String restPrimaryLabel = 'Iniciar';

          if (restNotifier != null) {
            switch (restStatus) {
              case RestTimerStatus.running:
                restPrimaryAction = () => restNotifier.pause();
                restPrimaryIcon = Icons.pause_circle_outline;
                restPrimaryLabel = 'Pausar';
                break;
              case RestTimerStatus.paused:
                restPrimaryAction = () => restNotifier.resume();
                restPrimaryIcon = Icons.play_circle_outline;
                restPrimaryLabel = 'Reanudar';
                break;
              case RestTimerStatus.completed:
              case RestTimerStatus.cancelled:
              case RestTimerStatus.idle:
                restPrimaryAction = () =>
                    restNotifier.start(config: restRequest!.config);
                restPrimaryIcon = Icons.play_circle_outline;
                restPrimaryLabel = 'Iniciar';
                break;
            }
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Modo entrenamiento en vivo'),
              actions: <Widget>[
                IconButton(
                  onPressed: state.isPersisted
                      ? null
                      : () async {
                          final bool leave = await _confirmExit(state);
                          if (!context.mounted) return;
                          if (leave) {
                            await _cancelRestTimer(restRequest);
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          }
                        },
                  icon: const Icon(Icons.close),
                  tooltip: 'Salir',
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _cancelRestTimer(restRequest);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              state.routine.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Duración: ${_formatDuration(_sessionElapsed)}',
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(value: progress),
                            const SizedBox(height: 8),
                            Text(
                              'Series completadas: $completedSets / $totalSets',
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (restRequest != null) ...<Widget>[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Cronómetro de descanso',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Objetivo: ${_formatDuration(restTarget)}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _formatDuration(restElapsed),
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                children: <Widget>[
                                  FilledButton.icon(
                                    onPressed: restPrimaryAction == null
                                        ? null
                                        : () => restPrimaryAction!(),
                                    icon: Icon(restPrimaryIcon),
                                    label: Text(restPrimaryLabel),
                                  ),
                                  TextButton(
                                    onPressed: restNotifier == null
                                        ? null
                                        : () async {
                                            await restNotifier.cancel();
                                            await restNotifier.start(
                                              config: restRequest.config,
                                            );
                                          },
                                    child: const Text('Reiniciar'),
                                  ),
                                ],
                              ),
                              if (restStatus == RestTimerStatus.completed)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Descanso completado',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (exercise != null && routineSet != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                exercise.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Serie ${routineSet.setNumber} de ${exercise.sets.length}',
                              ),
                              Text(
                                'Objetivo: ${routineSet.repetitions} reps · '
                                '${routineSet.targetWeight != null ? '${routineSet.targetWeight!.toStringAsFixed(1)} kg' : 'Peso libre'}',
                              ),
                              Text(
                                'Descanso sugerido: ${_formatDuration(recommendedRest)}',
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: state.isCompleted
                                    ? null
                                    : () => _logCurrentSet(state),
                                icon: const Icon(Icons.checklist_rtl),
                                label: const Text('Registrar serie'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildLoggedSetsSection(context, state),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Notas de la sesión',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _notesController,
                              maxLines: 3,
                              onChanged: (String value) => ref
                                  .read(
                                    routineSessionControllerProvider(
                                      widget.routineId,
                                    ).notifier,
                                  )
                                  .updateNotes(value),
                              decoration: const InputDecoration(
                                hintText: 'Sensaciones, ajustes o incidencias…',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: state.hasAnyLog && !state.isSaving
                          ? () => _finishSession(state)
                          : null,
                      child: state.isSaving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Finalizar y guardar sesión'),
                    ),
                    if (state.isPersisted)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Sesión guardada correctamente.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoggedSetsSection(
    BuildContext context,
    RoutineSessionState state,
  ) {
    if (!state.hasAnyLog) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Registro de la sesión',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('Aún no se han registrado series.'),
            ],
          ),
        ),
      );
    }

    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Registro de la sesión',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            for (final RoutineExercise exercise in state.routine.exercises)
              if (state.logs[exercise.exerciseId]?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...state.logs[exercise.exerciseId]!.map(
                        (SetLog log) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Serie ${log.setNumber}: ${log.repetitions} reps · '
                            '${log.weight.toStringAsFixed(1)} kg · Rest ${_formatDuration(log.restTaken)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _LogSetSheet extends StatefulWidget {
  const _LogSetSheet({
    required this.exercise,
    required this.routineSet,
    required this.initialRest,
  });

  final RoutineExercise exercise;
  final RoutineSet routineSet;
  final Duration initialRest;

  @override
  State<_LogSetSheet> createState() => _LogSetSheetState();
}

class _LogSetSheetState extends State<_LogSetSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(
      text: widget.routineSet.repetitions.toString(),
    );
    _weightController = TextEditingController(
      text: (widget.routineSet.targetWeight ?? 0).toStringAsFixed(1),
    );
    _restController = TextEditingController(
      text: widget.initialRest.inSeconds.toString(),
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Registrar serie — ${widget.exercise.name}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(labelText: 'Repeticiones'),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  final int? reps = int.tryParse(value ?? '');
                  if (reps == null) {
                    return 'Ingresa un número válido';
                  }
                  if (reps < 0 || reps > 100) {
                    return 'Usa un rango entre 0 y 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (String? value) {
                  final double? weight = double.tryParse(value ?? '');
                  if (weight == null || weight < 0) {
                    return 'Ingresa un peso mayor o igual a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _restController,
                decoration: const InputDecoration(
                  labelText: 'Descanso tomado (segundos)',
                ),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  final int? seconds = int.tryParse(value ?? '');
                  if (seconds == null) {
                    return 'Ingresa un número válido';
                  }
                  if (seconds < 0 || seconds > 1200) {
                    return 'El descanso debe ser entre 0 y 1200 segundos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) {
                    return;
                  }
                  final int repetitions =
                      int.parse(_repsController.text).clamp(0, 100) as int;
                  final double weight =
                      double.parse(
                            _weightController.text,
                          ).clamp(0, double.infinity)
                          as double;
                  final int restSeconds =
                      int.parse(_restController.text).clamp(0, 1200) as int;
                  Navigator.of(context).pop(
                    _LogSetResult(
                      repetitions: repetitions,
                      weight: weight,
                      restSeconds: restSeconds,
                    ),
                  );
                },
                child: const Text('Guardar serie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogSetResult {
  const _LogSetResult({
    required this.repetitions,
    required this.weight,
    required this.restSeconds,
  });

  final int repetitions;
  final double weight;
  final int restSeconds;
}
