import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/models/workout_plan.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_screen.dart';
import 'package:my_fitness_tracker/screens/exercises_screen.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final WorkoutService _workoutService;
  late Future<_HomeSummary> _summaryFuture;
  int _searchInteractions = 0;

  @override
  void initState() {
    super.initState();
    final workoutServiceAsync = ref.read(workoutServiceProvider);
    _workoutService = workoutServiceAsync;
    _summaryFuture = _loadSummary();
  }

  Future<_HomeSummary> _loadSummary() async {
    final today = DateTime.now();
    try {
      final workoutsResponse = await _workoutService.fetchExercises(limit: 6);
      return _HomeSummary(date: today, workouts: workoutsResponse.plans);
    } catch (error, stackTrace) {
      debugPrint('Error loading workouts: $error\n$stackTrace');
      return _HomeSummary(date: today, workouts: const <WorkoutPlan>[]);
    }
  }

  Future<void> _refresh() async {
    final freshSummary = await _loadSummary();
    if (!mounted) return;
    setState(() {
      _summaryFuture = Future<_HomeSummary>.value(freshSummary);
    });
  }

  void _openComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Las métricas corporales llegarán muy pronto.'),
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

  Future<void> _openRoutines() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RoutineListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routinesAsync = ref.watch(routineListControllerProvider);
    final routineCount = routinesAsync.maybeWhen(
      data: (List<Routine> routines) => routines.where((Routine r) => !r.isArchived).length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: FutureBuilder<_HomeSummary>(
          future: _summaryFuture,
          builder:
              (BuildContext context, AsyncSnapshot<_HomeSummary> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return _ErrorView(onRetry: _refresh);
                }

                final summary = snapshot.data!;
                final exercisesExplored = summary.workouts.length;
                final activityMoments = exercisesExplored + _searchInteractions + routineCount;

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _HeaderCard(date: summary.date),
                        const SizedBox(height: 24),
                        _ProgressCard(
                          exercises: exercisesExplored,
                          searches: _searchInteractions,
                          activityMoments: activityMoments,
                          routines: routineCount,
                        ),
                        const SizedBox(height: 24),
                        _SpotlightSection(workouts: summary.workouts),
                        const SizedBox(height: 24),
                        routinesAsync.when(
                          data: (List<Routine> routines) => GestureDetector(
                            onTap: _openRoutines,
                            child: _RoutineGlance(routines: routines, onCreateRoutine: _openRoutines),
                          ),
                          loading: () => const _RoutineGlance.loading(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              },
        ),
      ),
    );
  }
}

class _HomeSummary {
  const _HomeSummary({required this.date, required this.workouts});

  final DateTime date;
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
    required this.exercises,
    required this.searches,
    required this.activityMoments,
    required this.routines,
  });

  final int exercises;
  final int searches;
  final int activityMoments;
  final int routines;

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
              Icon(
                Icons.bar_chart_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
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
            icon: Icons.task_alt_rounded,
            label: '$routines rutinas activas',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _ProgressBullet(
            icon: Icons.fitness_center,
            label: '$exercises entrenamientos explorados',
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
            label: '$activityMoments interacciones totales',
            color: colorScheme.secondaryContainer,
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
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
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

class _RoutineGlance extends StatelessWidget {
  const _RoutineGlance({required this.routines, this.onCreateRoutine});
  const _RoutineGlance.loading() : routines = const <Routine>[], onCreateRoutine = null;

  final List<Routine> routines;
  final VoidCallback? onCreateRoutine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = routines.where((Routine routine) => !routine.isArchived).toList();
    if (active.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.flag_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Todavía no tienes rutinas activas. Crea la primera para comenzar a registrar tu progreso.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (onCreateRoutine != null)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onCreateRoutine,
              ),
          ],
        ),
      );
    }

    final preview = active.take(3).map((Routine routine) => routine.name).join(' • ');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Rutinas activas',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
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
  const _FixedActionBar({
    required this.onMetricsTap,
    required this.onExercisesTap,
  });

  final VoidCallback onMetricsTap;
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
              icon: '📈',
              label: 'MÉTRICAS',
              background: theme.colorScheme.primaryContainer,
              foreground: theme.colorScheme.onPrimaryContainer,
              onTap: onMetricsTap,
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
