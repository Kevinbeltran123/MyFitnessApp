import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/models/workout_plan.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';
import 'package:my_fitness_tracker/presentation/routines/widgets/routine_exercise_picker.dart';
import 'package:my_fitness_tracker/presentation/routines/widgets/routine_set_editor.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';

class RoutineBuilderScreen extends ConsumerStatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  ConsumerState<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends ConsumerState<RoutineBuilderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Set<RoutineDay> _selectedDays = <RoutineDay>{const RoutineDay(DateTime.monday)};
  final List<_RoutineExerciseDraft> _exercises = <_RoutineExerciseDraft>[];

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      _exercises.add(
        _RoutineExerciseDraft(
          plan: plan,
          sets: const <RoutineSet>[RoutineSet(setNumber: 1, repetitions: 12)],
        ),
      );
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
    final routineServiceAsync = ref.read(routineServiceProvider);
    final routineService = routineServiceAsync.value;
    if (routineService == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio no disponible.')), 
      );
      return;
    }

    final DateTime now = DateTime.now();
    final routine = Routine(
      id: now.microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      focus: RoutineFocus.fullBody,
      daysOfWeek: _selectedDays.toList(),
      exercises: _exercises
          .asMap()
          .entries
          .map(
            (MapEntry<int, _RoutineExerciseDraft> entry) => RoutineExercise(
              exerciseId: entry.value.plan.exerciseId,
              name: entry.value.plan.name,
              order: entry.key,
              sets: entry.value.sets,
              targetMuscles: entry.value.plan.targetMuscles,
              notes: null,
              equipment: entry.value.plan.equipments.isNotEmpty
                  ? entry.value.plan.equipments.first
                  : null,
              gifUrl: entry.value.plan.gifUrl,
            ),
          )
          .toList(),
      createdAt: now,
      updatedAt: now,
      notes: null,
      isArchived: false,
    );

    await routineService.create(routine);
    await ref.read(routineListControllerProvider.notifier).refresh();
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rutina "${routine.name}" creada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workoutService = ref.watch(workoutServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva rutina'),
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
                        selected: _selectedDays.contains(RoutineDay(entry.key + 1)),
                        onSelected: (_) => _toggleDay(entry.key + 1),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Text('Ejercicios (${_exercises.length})', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _openExercisePicker(context, workoutService),
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
                  children: _exercises
                      .asMap()
                      .entries
                      .map(
                        (MapEntry<int, _RoutineExerciseDraft> entry) {
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
                                        _exercises[entry.key] = draft.copyWith(sets: sets);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openExercisePicker(BuildContext context, WorkoutService service) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
  const _RoutineExerciseDraft({required this.plan, required this.sets});

  final WorkoutPlan plan;
  final List<RoutineSet> sets;

  _RoutineExerciseDraft copyWith({List<RoutineSet>? sets}) {
    return _RoutineExerciseDraft(plan: plan, sets: sets ?? this.sets);
  }
}
