import 'dart:async';

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
  Timer? _debounce;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _resultsFuture = _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<List<WorkoutPlan>> _search([String query = '']) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      final response = await widget.workoutService.fetchExercises(limit: 20);
      return response.plans;
    }

    final response = await widget.workoutService.searchExercises(
      trimmed,
      limit: 20,
    );
    return response.plans;
  }

  void _onQueryChanged(String value) {
    setState(() {
      _lastQuery = value;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _resultsFuture = _search(value);
      });
    });
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
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (_queryController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Limpiar búsqueda',
                    onPressed: () {
                      _queryController.clear();
                      _onQueryChanged('');
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _resultsFuture = _search(_queryController.text);
                    });
                  },
                ),
              ],
            ),
          ),
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
          onSubmitted: (String value) {
            _debounce?.cancel();
            setState(() {
              _lastQuery = value;
              _resultsFuture = _search(value);
            });
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<WorkoutPlan>>(
            future: _resultsFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<WorkoutPlan>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'No pudimos cargar ejercicios',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _resultsFuture = _search(_lastQuery);
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
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
