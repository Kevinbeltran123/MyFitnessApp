import 'package:flutter/material.dart';

import '../models/nutrition_entry.dart';
import '../models/workout_plan.dart';
import '../services/api_client.dart';
// import '../services/nutrition_service.dart';
import '../services/workout_service.dart';
import 'exercises_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiClient _apiClient;
  late final WorkoutService _workoutService;
  late Future<_HomeSummary> _summaryFuture;
  int _searchInteractions = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _workoutService = WorkoutService(_apiClient);
    _summaryFuture = _loadSummary();
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  Future<_HomeSummary> _loadSummary() async {
    final today = DateTime.now();
    try {
      final workoutsResponse = await _workoutService.fetchExercises(limit: 6);
      return _HomeSummary(
        date: today,
        nutrition: const <NutritionEntry>[],
        workouts: workoutsResponse.plans,
      );
    } catch (error, stackTrace) {
      debugPrint('Error loading workouts: $error\n$stackTrace');
      return _HomeSummary(
        date: today,
        nutrition: const <NutritionEntry>[],
        workouts: const <WorkoutPlan>[],
      );
    }
  }

  Future<void> _refresh() async {
    final freshSummary = await _loadSummary();
    if (!mounted) return;
    setState(() {
      _summaryFuture = Future<_HomeSummary>.value(freshSummary);
    });
  }

  void _openMeals() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La sección de comidas estará disponible pronto.'),
      ),
    );
  }

  Future<void> _openExercises() async {
    setState(() => _searchInteractions += 1);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ExercisesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: FutureBuilder<_HomeSummary>(
          future: _summaryFuture,
          builder: (BuildContext context, AsyncSnapshot<_HomeSummary> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorView(onRetry: _refresh);
            }

            final summary = snapshot.data!;
            final totalCalories = summary.nutrition.fold<int>(
              0,
              (int sum, NutritionEntry item) => sum + item.calories,
            );
            final exercisesExplored = summary.workouts.length;
            final activityMoments = summary.nutrition.length + exercisesExplored + _searchInteractions;

            return Column(
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _HeaderCard(date: summary.date),
                          const SizedBox(height: 24),
                          _ProgressCard(
                            calories: totalCalories,
                            exercises: exercisesExplored,
                            searches: _searchInteractions,
                            activityMoments: activityMoments,
                          ),
                          const SizedBox(height: 24),
                          _SpotlightSection(workouts: summary.workouts),
                        ],
                      ),
                    ),
                  ),
                ),
                _FixedActionBar(
                  onMealsTap: _openMeals,
                  onExercisesTap: _openExercises,
                ),
              ],
            );
          },
        ),
      ),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Hola! 👋',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Qué quieres hacer hoy?',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _formatFriendlyDate(date),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.85),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.calories,
    required this.exercises,
    required this.searches,
    required this.activityMoments,
  });

  final int calories;
  final int exercises;
  final int searches;
  final int activityMoments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(26),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.bar_chart_rounded, color: colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Tu progreso hoy 📊',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressBullet(
            icon: Icons.local_fire_department,
            label: '$calories kcal consumidas',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _ProgressBullet(
            icon: Icons.fitness_center,
            label: '$exercises ejercicios vistos',
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          _ProgressBullet(
            icon: Icons.travel_explore,
            label: '$searches búsquedas realizadas',
            color: colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          _ProgressBullet(
            icon: Icons.bolt,
            label: '$activityMoments momentos de actividad',
            color: colorScheme.primaryContainer,
          ),
        ],
      ),
    );
  }
}

class _ProgressBullet extends StatelessWidget {
  const _ProgressBullet({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightSection extends StatelessWidget {
  const _SpotlightSection({required this.workouts});

  final List<WorkoutPlan> workouts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasData = workouts.isNotEmpty;
    final workout = hasData ? workouts.first : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: hasData
              ? <Color>[
                  colorScheme.secondaryContainer,
                  colorScheme.primaryContainer.withValues(alpha: 0.9),
                ]
              : <Color>[
                  colorScheme.surfaceContainerHigh,
                  colorScheme.surfaceContainerHighest,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: hasData
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Próximo desafío',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  workout!.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    if (workout.primaryTarget.isNotEmpty)
                      _TagChip(workout.primaryTarget),
                    ...workout.bodyParts.take(2).map((bp) => _TagChip(bp)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  workout.instructions.take(2).join('\n'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'Agregaremos recomendaciones personalizadas aquí.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(label),
      backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _FixedActionBar extends StatelessWidget {
  const _FixedActionBar({required this.onMealsTap, required this.onExercisesTap});

  final VoidCallback onMealsTap;
  final VoidCallback onExercisesTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _BottomActionButton(
              icon: '🍎',
              label: 'COMIDAS',
              background: theme.colorScheme.primaryContainer,
              foreground: theme.colorScheme.onPrimaryContainer,
              onTap: onMealsTap,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _BottomActionButton(
              icon: '💪',
              label: 'EJERCICIOS',
              background: theme.colorScheme.primary,
              foreground: theme.colorScheme.onPrimary,
              onTap: onExercisesTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(22),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: background.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.wifi_off, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'No pudimos actualizar tu dashboard.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatFriendlyDate(DateTime date) {
  const months = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  final month = months[date.month - 1];
  return '${date.day} de $month ${date.year}';
}
