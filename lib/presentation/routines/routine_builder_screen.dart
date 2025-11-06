import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/models/workout_plan.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';
import 'package:my_fitness_tracker/presentation/routines/widgets/routine_exercise_picker.dart';
import 'package:my_fitness_tracker/presentation/routines/widgets/routine_set_editor.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';

class RoutineBuilderScreen extends ConsumerStatefulWidget {
  const RoutineBuilderScreen({super.key, this.initialRoutine});

  final Routine? initialRoutine;

  bool get isEditing => initialRoutine != null;

  @override
  ConsumerState<RoutineBuilderScreen> createState() =>
      _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends ConsumerState<RoutineBuilderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final SplayTreeSet<RoutineDay> _selectedDays = SplayTreeSet<RoutineDay>(
    (RoutineDay a, RoutineDay b) => a.weekday.compareTo(b.weekday),
  )..add(const RoutineDay(DateTime.monday));
  final List<_RoutineExerciseDraft> _exercises = <_RoutineExerciseDraft>[];
  RoutineFocus _selectedFocus = RoutineFocus.fullBody;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final Routine? routine = widget.initialRoutine;
    if (routine != null) {
      _applyRoutine(routine);
    }
  }

  @override
  void didUpdateWidget(covariant RoutineBuilderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Routine? routine = widget.initialRoutine;
    if (routine != null && routine != oldWidget.initialRoutine) {
      setState(() {
        _applyRoutine(routine);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyRoutine(Routine routine) {
    _nameController.text = routine.name;
    _descriptionController.text = routine.description;
    _selectedFocus = routine.focus;
    _selectedDays
      ..clear()
      ..addAll(routine.daysOfWeek);
    _exercises
      ..clear()
      ..addAll(
        routine.exercises.map(_RoutineExerciseDraft.fromRoutineExercise),
      );
  }

  void _toggleDay(int weekday) {
    final RoutineDay day = RoutineDay(weekday);
    final bool alreadySelected = _selectedDays.contains(day);
    if (alreadySelected && _selectedDays.length == 1) {
      AppSnackBar.showWarning(
        context,
        'La rutina debe tener al menos un día asignado.',
      );
      return;
    }

    setState(() {
      if (alreadySelected) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  String _focusLabel(RoutineFocus focus) {
    switch (focus) {
      case RoutineFocus.fullBody:
        return 'Cuerpo completo';
      case RoutineFocus.upperBody:
        return 'Tren superior';
      case RoutineFocus.lowerBody:
        return 'Tren inferior';
      case RoutineFocus.push:
        return 'Push';
      case RoutineFocus.pull:
        return 'Pull';
      case RoutineFocus.core:
        return 'Core';
      case RoutineFocus.mobility:
        return 'Movilidad';
      case RoutineFocus.custom:
        return 'Personalizada';
    }
  }

  void _addExercise(WorkoutPlan plan) {
    setState(() {
      _exercises.add(_RoutineExerciseDraft.fromWorkoutPlan(plan));
    });
    Navigator.of(context).pop();
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDays.isEmpty) {
      AppSnackBar.showWarning(
        context,
        'Selecciona al menos un día para la rutina.',
      );
      return;
    }
    if (_exercises.isEmpty) {
      AppSnackBar.showWarning(context, 'Agrega al menos un ejercicio.');
      return;
    }

    for (final _RoutineExerciseDraft draft in _exercises) {
      final String exerciseName = draft.plan.name;
      if (draft.sets.isEmpty) {
        AppSnackBar.showWarning(
          context,
          '"$exerciseName" debe incluir al menos una serie.',
        );
        return;
      }
      if (draft.sets.length > 10) {
        AppSnackBar.showWarning(
          context,
          '"$exerciseName" admite máximo 10 series.',
        );
        return;
      }
      for (final RoutineSet set in draft.sets) {
        if (set.repetitions < 1 || set.repetitions > 100) {
          AppSnackBar.showWarning(
            context,
            'Las repeticiones de "$exerciseName" deben estar entre 1 y 100.',
          );
          return;
        }
        if (set.targetWeight != null && set.targetWeight! < 0) {
          AppSnackBar.showWarning(
            context,
            'El peso en "$exerciseName" debe ser positivo.',
          );
          return;
        }
        final Duration? rest = set.restInterval;
        if (rest != null &&
            (rest.isNegative || rest > const Duration(minutes: 20))) {
          AppSnackBar.showWarning(
            context,
            'El descanso en "$exerciseName" debe ser entre 0 y 20 minutos.',
          );
          return;
        }
      }
    }
    setState(() => _isSaving = true);
    final Routine? initial = widget.initialRoutine;
    Routine? savedRoutine;

    try {
      final RoutineService routineService = await ref.read(
        routineServiceProvider.future,
      );

      final DateTime now = DateTime.now();
      final Routine routine = Routine(
        id: initial?.id ?? now.microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        focus: _selectedFocus,
        daysOfWeek: List<RoutineDay>.from(_selectedDays),
        exercises: _exercises
            .asMap()
            .entries
            .map((MapEntry<int, _RoutineExerciseDraft> entry) {
              final _RoutineExerciseDraft draft = entry.value;
              return RoutineExercise(
                exerciseId: draft.plan.exerciseId,
                name: draft.plan.name,
                order: entry.key,
                sets: List<RoutineSet>.from(draft.sets),
                targetMuscles: draft.plan.targetMuscles,
                notes: draft.notes,
                equipment:
                    draft.equipment ??
                    (draft.plan.equipments.isNotEmpty
                        ? draft.plan.equipments.first
                        : null),
                gifUrl: draft.plan.gifUrl,
              );
            })
            .toList(growable: false),
        createdAt: initial?.createdAt ?? now,
        updatedAt: now,
        notes: initial?.notes,
        isArchived: initial?.isArchived ?? false,
      );

      if (initial == null) {
        await routineService.create(routine);
      } else {
        await routineService.update(routine);
      }

      await ref.read(routineListControllerProvider.notifier).refresh();
      savedRoutine = routine;
    } on FormatException catch (error) {
      if (mounted) {
        AppSnackBar.showError(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'No pudimos guardar la rutina. Intenta nuevamente.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (!mounted || savedRoutine == null) {
      return;
    }

    Navigator.of(context).pop(savedRoutine);
    AppSnackBar.showSuccess(
      context,
      initial == null
          ? 'Rutina "${savedRoutine.name}" creada.'
          : 'Rutina "${savedRoutine.name}" actualizada.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workoutService = ref.watch(workoutServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar rutina' : 'Nueva rutina'),
        actions: <Widget>[
          TextButton(
            onPressed: _isSaving ? null : _saveRoutine,
            child: _isSaving
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la rutina',
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  if (value.trim().length < 3) {
                    return 'Usa al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RoutineFocus>(
                key: ValueKey<RoutineFocus>(_selectedFocus),
                initialValue: _selectedFocus,
                decoration: const InputDecoration(labelText: 'Enfoque'),
                items: RoutineFocus.values
                    .map(
                      (RoutineFocus focus) => DropdownMenuItem<RoutineFocus>(
                        value: focus,
                        child: Text(_focusLabel(focus)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (RoutineFocus? focus) {
                  if (focus == null) {
                    return;
                  }
                  setState(() => _selectedFocus = focus);
                },
              ),
              const SizedBox(height: 16),
              Text('Días de entrenamiento', style: theme.textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: RoutineDay.shortLabels
                    .asMap()
                    .entries
                    .map(
                      (MapEntry<int, String> entry) => FilterChip(
                        label: Text(entry.value),
                        selected: _selectedDays.contains(
                          RoutineDay(entry.key + 1),
                        ),
                        onSelected: (_) => _toggleDay(entry.key + 1),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Text(
                    'Ejercicios (${_exercises.length})',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        _openExercisePicker(context, workoutService),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar ejercicio'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_exercises.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Aún no has agregado ejercicios.'),
                )
              else
                Column(
                  children: _exercises.asMap().entries.map((
                    MapEntry<int, _RoutineExerciseDraft> entry,
                  ) {
                    final draft = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    draft.plan.name,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _exercises.removeAt(entry.key);
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            RoutineSetEditor(
                              initialSets: draft.sets,
                              onChanged: (List<RoutineSet> sets) {
                                setState(() {
                                  _exercises[entry.key] = draft.copyWith(
                                    sets: sets,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openExercisePicker(
    BuildContext context,
    WorkoutService service,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: RoutineExercisePicker(
              workoutService: service,
              onExerciseSelected: _addExercise,
            ),
          ),
        );
      },
    );
  }
}

class _RoutineExerciseDraft {
  const _RoutineExerciseDraft({
    required this.plan,
    required this.sets,
    this.notes,
    this.equipment,
  });

  final WorkoutPlan plan;
  final List<RoutineSet> sets;
  final String? notes;
  final String? equipment;

  factory _RoutineExerciseDraft.fromWorkoutPlan(WorkoutPlan plan) {
    return _RoutineExerciseDraft(
      plan: plan,
      sets: const <RoutineSet>[RoutineSet(setNumber: 1, repetitions: 12)],
      equipment: plan.equipments.isNotEmpty ? plan.equipments.first : null,
    );
  }

  factory _RoutineExerciseDraft.fromRoutineExercise(RoutineExercise exercise) {
    return _RoutineExerciseDraft(
      plan: WorkoutPlan(
        exerciseId: exercise.exerciseId,
        name: exercise.name,
        gifUrl: exercise.gifUrl ?? '',
        targetMuscles: exercise.targetMuscles,
        bodyParts: const <String>[],
        equipments: exercise.equipment != null
            ? <String>[exercise.equipment!]
            : const <String>[],
        secondaryMuscles: const <String>[],
        instructions: const <String>[],
      ),
      sets: List<RoutineSet>.from(exercise.sets),
      notes: exercise.notes,
      equipment: exercise.equipment,
    );
  }

  _RoutineExerciseDraft copyWith({List<RoutineSet>? sets}) {
    return _RoutineExerciseDraft(
      plan: plan,
      sets: sets ?? this.sets,
      notes: notes,
      equipment: equipment,
    );
  }
}
