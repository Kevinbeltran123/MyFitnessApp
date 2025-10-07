import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_session_controller.dart';

class RoutineSessionScreen extends ConsumerStatefulWidget {
  const RoutineSessionScreen({super.key, required this.routineId});

  final String routineId;

  @override
  ConsumerState<RoutineSessionScreen> createState() =>
      _RoutineSessionScreenState();
}

class _RoutineSessionScreenState extends ConsumerState<RoutineSessionScreen> {
  Timer? _sessionTicker;
  Timer? _restTicker;
  DateTime? _sessionStartedAt;
  DateTime? _restStartedAt;
  Duration _sessionElapsed = Duration.zero;
  Duration _restElapsed = Duration.zero;
  Duration? _restTarget;
  Duration? _lastCapturedRest;
  bool _restRunning = false;

  final TextEditingController _notesController = TextEditingController();
  bool _notesInitialized = false;

  @override
  void dispose() {
    _sessionTicker?.cancel();
    _restTicker?.cancel();
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

  void _startRest(Duration suggested) {
    _restTicker?.cancel();
    _restStartedAt = DateTime.now();
    _restElapsed = Duration.zero;
    _restTarget = suggested;
    _restRunning = true;
    _restTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _restStartedAt == null) {
        return;
      }
      setState(() {
        _restElapsed = DateTime.now().difference(_restStartedAt!);
      });
    });
    setState(() {});
  }

  void _stopRest({bool capture = true}) {
    _restTicker?.cancel();
    if (capture && _restStartedAt != null) {
      _lastCapturedRest = DateTime.now().difference(_restStartedAt!);
    }
    _restStartedAt = null;
    _restElapsed = Duration.zero;
    _restTarget = null;
    _restRunning = false;
    setState(() {});
  }

  void _resetRest() {
    _restTicker?.cancel();
    _restStartedAt = null;
    _restElapsed = Duration.zero;
    _restTarget = null;
    _restRunning = false;
    _lastCapturedRest = null;
    setState(() {});
  }

  Duration _defaultRestFor(RoutineSet? set) {
    if (set?.restInterval != null) {
      return set!.restInterval!;
    }
    return const Duration(seconds: 90);
  }

  Future<void> _logCurrentSet(RoutineSessionState state) async {
    final RoutineExercise? exercise = state.currentExercise;
    final RoutineSet? routineSet = state.currentSet;
    if (exercise == null || routineSet == null) {
      return;
    }
    if (_restRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detén el descanso antes de registrar la serie.'),
        ),
      );
      return;
    }

    final Duration suggestedRest = _defaultRestFor(routineSet);
    final Duration initialRest = _lastCapturedRest ?? suggestedRest;

    final _LogSetResult? result = await showModalBottomSheet<_LogSetResult>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _LogSetSheet(
          exercise: exercise,
          routineSet: routineSet,
          initialRest: initialRest,
        );
      },
    );

    if (result == null) {
      return;
    }

    await ref
        .read(routineSessionControllerProvider(widget.routineId).notifier)
        .recordSet(
          repetitions: result.repetitions,
          weight: result.weight,
          restTaken: Duration(seconds: result.restSeconds),
        );

    setState(() {
      _lastCapturedRest = null;
    });

    final RoutineSessionState? updated = ref
        .read(routineSessionControllerProvider(widget.routineId))
        .value;
    if (!mounted || updated == null) {
      return;
    }
    if (!updated.isCompleted) {
      final RoutineSet? nextSet = updated.currentSet;
      _startRest(_defaultRestFor(nextSet ?? routineSet));
    } else {
      _stopRest(capture: false);
      await _showCompletionSheet(updated);
    }
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              ref
                  .read(
                    routineSessionControllerProvider(widget.routineId).notifier,
                  )
                  .clearError();
            });
          }
          _ensureSessionTimer(state.startedAt);
          final RoutineExercise? exercise = state.currentExercise;
          final RoutineSet? routineSet = state.currentSet;
          final int totalSets = max(state.totalSets, 1);
          final int completedSets = state.completedSets;
          final double progress = completedSets / totalSets;
          final Duration recommendedRest = _defaultRestFor(routineSet);

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
                  _resetRest();
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
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Cronómetro de descanso',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (_restTarget != null)
                                  Text(
                                    'Objetivo: ${_formatDuration(_restTarget!)}',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _formatDuration(_restElapsed),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              children: <Widget>[
                                FilledButton.icon(
                                  onPressed: _restRunning
                                      ? () => _stopRest()
                                      : () => _startRest(recommendedRest),
                                  icon: Icon(
                                    _restRunning
                                        ? Icons.stop_circle_outlined
                                        : Icons.play_circle_outline,
                                  ),
                                  label: Text(
                                    _restRunning ? 'Detener' : 'Iniciar',
                                  ),
                                ),
                                TextButton(
                                  onPressed: _restRunning ? _resetRest : null,
                                  child: const Text('Reiniciar'),
                                ),
                              ],
                            ),
                            if (_lastCapturedRest != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Último descanso registrado: ${_formatDuration(_lastCapturedRest!)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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
                              if (routineSet.restInterval != null)
                                Text(
                                  'Descanso sugerido: ${_formatDuration(routineSet.restInterval!)}',
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
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
                  if (reps == null || reps <= 0) {
                    return 'Ingresa repeticiones válidas';
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
                    return 'Ingresa un peso válido';
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
                  if (seconds == null || seconds < 0) {
                    return 'Ingresa segundos válidos';
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
                  final int repetitions = int.parse(_repsController.text);
                  final double weight = double.parse(_weightController.text);
                  final int restSeconds = int.parse(_restController.text);
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
