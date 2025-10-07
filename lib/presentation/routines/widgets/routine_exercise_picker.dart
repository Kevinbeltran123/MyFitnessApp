import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/models/workout_plan.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';

class RoutineExercisePicker extends StatefulWidget {
  const RoutineExercisePicker({
    super.key,
    required this.workoutService,
    required this.onExerciseSelected,
  });

  final WorkoutService workoutService;
  final ValueChanged<WorkoutPlan> onExerciseSelected;

  @override
  State<RoutineExercisePicker> createState() => _RoutineExercisePickerState();
}

class _RoutineExercisePickerState extends State<RoutineExercisePicker> {
  final TextEditingController _queryController = TextEditingController();
  late Future<List<WorkoutPlan>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _search();
  }

  Future<List<WorkoutPlan>> _search() async {
    final response = await widget.workoutService.fetchExercises(limit: 20);
    return response.plans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _queryController,
          decoration: InputDecoration(
            hintText: 'Buscar ejercicio',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _resultsFuture = _search();
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<WorkoutPlan>>(
            future: _resultsFuture,
            builder: (BuildContext context, AsyncSnapshot<List<WorkoutPlan>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Text(
                    'No pudimos cargar ejercicios',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }
              final List<WorkoutPlan> plans = snapshot.data!;
              if (plans.isEmpty) {
                return Center(
                  child: Text(
                    'Sin resultados',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }
              return ListView.separated(
                itemCount: plans.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  final WorkoutPlan plan = plans[index];
                  return ListTile(
                    title: Text(plan.name),
                    subtitle: Text(plan.targetMuscles.join(' • ')),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () => widget.onExerciseSelected(plan),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
