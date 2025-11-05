import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/models/workout_plan.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/quick_weight_logger_dialog.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final WorkoutService _workoutService;
  late Future<_HomeSummary> _summaryFuture;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showQuickWeightLoggerDialog(context, ref);
          if (!mounted || result == null) return;
          AppSnackBar.showSuccess(
            context,
            'Peso registrado: ${result.toStringAsFixed(1)} kg',
          );
        },
        icon: const Icon(Icons.monitor_weight_outlined),
        label: const Text('Peso rápido'),
      ),
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

            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _HeaderCard(date: summary.date),
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
