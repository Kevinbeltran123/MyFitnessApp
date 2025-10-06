import 'package:flutter/material.dart';

import '../models/nutrition_entry.dart';
import '../models/workout_plan.dart';
import '../services/api_client.dart';
// import '../services/nutrition_service.dart'; // Temporalmente comentado
import '../services/workout_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/summary_card.dart';
import '../widgets/workout_detail_sheet.dart';
import 'exercises_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiClient _apiClient;
  // late final NutritionService _nutritionService; // Temporalmente comentado
  late final WorkoutService _workoutService;
  late final Future<_HomeSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    // _nutritionService = NutritionService(_apiClient); // Temporalmente comentado
    _workoutService = WorkoutService(_apiClient);
    _summaryFuture = _loadSummary();
  }

  Future<_HomeSummary> _loadSummary() async {
    final today = DateTime.now();

    // Por ahora solo cargamos ejercicios hasta que arreglemos la API de nutrición
    try {
      final workoutsResponse = await _workoutService.fetchExercises(limit: 6);
      return _HomeSummary(
        date: today,
        nutrition: [], // Lista vacía por ahora
        workouts: workoutsResponse.plans,
      );
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Fitness Tracker')),
      body: FutureBuilder<_HomeSummary>(
        future: _summaryFuture,
        builder: (BuildContext context, AsyncSnapshot<_HomeSummary> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudo cargar la información. Intenta más tarde.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Sin datos disponibles.'));
          }
          final summary = snapshot.data!;
          final totalCalories = summary.nutrition.fold<int>(
            0,
            (int sum, NutritionEntry item) => sum + item.calories,
          );
          final nextWorkout = summary.workouts.isNotEmpty
              ? summary.workouts.first
              : null;

          return RefreshIndicator(
            onRefresh: () async {
              final freshSummary = await _loadSummary();
              if (!mounted) {
                return;
              }
              setState(() {
                _summaryFuture = Future<_HomeSummary>.value(freshSummary);
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text(
                  'Resumen del ${formatShortDate(summary.date)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Calorías consumidas',
                  value: '$totalCalories kcal',
                  onTap: () {
                    // TODO: Navegar al detalle de nutrición.
                  },
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Registro de comidas',
                  value: '${summary.nutrition.length} items',
                  onTap: () {
                    // TODO: Navegar al historial de comidas.
                  },
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Próximo entrenamiento',
                  value: nextWorkout != null
                      ? '${nextWorkout.name} · ${nextWorkout.primaryTarget}'
                      : 'Sin recomendación disponible',
                  onTap: () {
                    if (nextWorkout != null) {
                      _openWorkoutDetail(nextWorkout);
                    }
                  },
                ),
                if (summary.workouts.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 20),
                  Text(
                    'Entrenamientos recomendados',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...summary.workouts.map(
                    (WorkoutPlan plan) => _WorkoutCard(
                      plan: plan,
                      onTap: () => _openWorkoutDetail(plan),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const ExercisesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.fitness_center),
                      label: const Text('Ver todos los ejercicios'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _openWorkoutDetail(WorkoutPlan plan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return WorkoutDetailSheet(plan: plan);
      },
    );
  }
}

class _HomeSummary {
  const _HomeSummary({
    required this.date,
    required this.nutrition,
    required this.workouts,
  });

  final DateTime date;
  final List<NutritionEntry> nutrition;
  final List<WorkoutPlan> workouts;
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.plan, required this.onTap});

  final WorkoutPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = plan.secondaryMuscles.isNotEmpty
        ? plan.secondaryMuscles.take(3).join(', ')
        : 'Sin músculos secundarios';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _WorkoutThumbnail(gifUrl: plan.gifUrl, name: plan.name),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(plan.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Principal: ${plan.primaryTarget}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Secundarios: $secondary',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutThumbnail extends StatelessWidget {
  const _WorkoutThumbnail({required this.gifUrl, required this.name});

  final String gifUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final placeholder = CircleAvatar(radius: 30, child: Text(_initial(name)));

    if (gifUrl.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        gifUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}

String _initial(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed[0].toUpperCase();
}
