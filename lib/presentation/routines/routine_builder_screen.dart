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
  final Set<RoutineDay> _selectedDays = <RoutineDay>{
    const RoutineDay(DateTime.monday),
  };
  final List<_RoutineExerciseDraft> _exercises = <_RoutineExerciseDraft>[];

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
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
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
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un ejercicio.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    late final RoutineService routineService;
    try {
      routineService = await ref.read(routineServiceProvider.future);
    } catch (error) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio no disponible.')),
        );
      }
      return;
    }

    final DateTime now = DateTime.now();
    final Routine? initial = widget.initialRoutine;
    final routine = Routine(
      id: initial?.id ?? now.microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      focus: initial?.focus ?? RoutineFocus.fullBody,
      daysOfWeek: _selectedDays.toList(),
      exercises: _exercises.asMap().entries.map((
        MapEntry<int, _RoutineExerciseDraft> entry,
      ) {
        final draft = entry.value;
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
      }).toList(),
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
    if (!mounted) return;
    setState(() => _isSaving = false);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(routine);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          initial == null
              ? 'Rutina "${routine.name}" creada.'
              : 'Rutina "${routine.name}" actualizada.',
        ),
      ),
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
