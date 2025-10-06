import 'package:flutter/material.dart';

import '../models/nutrition_entry.dart';
import '../models/workout_plan.dart';
import '../services/api_client.dart';
// import '../services/nutrition_service.dart'; // Temporalmente deshabilitado
import '../services/workout_service.dart';
import 'exercises_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiClient _apiClient;
  // late final NutritionService _nutritionService; // Temporalmente deshabilitado
  late final WorkoutService _workoutService;
  late Future<_HomeSummary> _summaryFuture;

  int _searchInteractions = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    // _nutritionService = NutritionService(_apiClient); // Temporalmente deshabilitado
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
      // Solo ejercicios hasta que la API de nutrición vuelva a responder JSON.
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
    if (!mounted) {
      return;
    }
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
    setState(() {
      _searchInteractions += 1;
    });
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

            if (snapshot.hasError) {
              return _ErrorView(onRetry: _refresh);
            }

            if (!snapshot.hasData) {
              return _ErrorView(onRetry: _refresh);
            }

            final summary = snapshot.data!;
            final totalCalories = summary.nutrition.fold<int>(
              0,
              (int sum, NutritionEntry item) => sum + item.calories,
            );
            final exercisesExplored = summary.workouts.length;
            final activityMoments = summary.nutrition.length + exercisesExplored + _searchInteractions;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _HeaderCard(date: summary.date),
                          const SizedBox(height: 28),
                          _ActionCard(
                            emoji: '🍎',
                            title: 'EXPLORAR COMIDAS',
                            subtitle: 'Descubre opciones saludables',
                            gradient: LinearGradient(
                              colors: <Color>[
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: _openMeals,
                          ),
                          const SizedBox(height: 20),
                          _ActionCard(
                            emoji: '💪',
                            title: 'ENCONTRAR EJERCICIOS',
                            subtitle: 'Rutinas para todo el cuerpo',
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFF4CAF50),
                                Color(0xFF2E7D32),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: _openExercises,
                          ),
                          const SizedBox(height: 28),
                          _ProgressCard(
                            calories: totalCalories,
                            exercises: exercisesExplored,
                            searches: _searchInteractions,
                            activityMoments: activityMoments,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
    final friendlyDate = _formatFriendlyDate(date);

    return Container(
      width: double.infinity,
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
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
            friendlyDate,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(26),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tu progreso hoy 📊',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
