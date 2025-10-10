import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Comprehensive statistics screen showing all fitness data.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(workoutHistoryControllerProvider);
    final routinesAsync = ref.watch(routineListControllerProvider);
    final metricsAsync = ref.watch(bodyMetricsProvider);
    final profileAsync = ref.watch(metabolicProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(workoutHistoryControllerProvider);
            ref.invalidate(routineListControllerProvider);
            ref.invalidate(bodyMetricsProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Overview card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.grayGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.insights,
                            color: AppColors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Resumen General',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildOverviewStats(
                        context,
                        theme,
                        sessionsAsync.value ?? [],
                        routinesAsync.value ?? [],
                        metricsAsync.value ?? [],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Workout statistics
                Text(
                  'Entrenamientos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                sessionsAsync.when(
                  data: (sessions) => _buildWorkoutStats(context, theme, sessions),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Metrics statistics
                Text(
                  'Progreso Corporal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                metricsAsync.when(
                  data: (metrics) => _buildMetricsStats(
                    context,
                    theme,
                    metrics,
                    profileAsync.value,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Routines statistics
                Text(
                  'Rutinas',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                routinesAsync.when(
                  data: (routines) => _buildRoutineStats(context, theme, routines),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStats(
    BuildContext context,
    ThemeData theme,
    List sessions,
    List routines,
    List metrics,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewItem(
            theme,
            '${sessions.length}',
            'Entrenamientos',
          ),
        ),
        Expanded(
          child: _buildOverviewItem(
            theme,
            '${routines.where((r) => !r.isArchived).length}',
            'Rutinas Activas',
          ),
        ),
        Expanded(
          child: _buildOverviewItem(
            theme,
            '${metrics.length}',
            'Medidas',
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWorkoutStats(
    BuildContext context,
    ThemeData theme,
    List<dynamic> sessions,
  ) {
    if (sessions.isEmpty) {
      return _buildEmptyState('Sin entrenamientos registrados');
    }

    // Calculate total stats
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.completedAt.difference(session.startedAt),
    );

    final totalSets = sessions.fold<int>(
      0,
      (sum, session) => (sum + session.exerciseLogs.fold<int>(
            0,
            (s, log) => s + (log.setLogs.length as int),
          )) as int,
    );

    final totalVolume = sessions.fold<double>(
      0.0,
      (sum, session) => sum + session.exerciseLogs.fold<double>(
            0.0,
            (s, log) => s + log.setLogs.fold<double>(
                  0.0,
                  (v, set) => v + (set.weight * set.repetitions),
                ),
          ),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.timer_outlined,
                label: 'Tiempo Total',
                value: '${totalDuration.inHours}h ${totalDuration.inMinutes.remainder(60)}m',
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.repeat,
                label: 'Series Totales',
                value: '$totalSets',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.trending_up,
          label: 'Volumen Total',
          value: '${totalVolume.toStringAsFixed(0)} kg',
          color: AppColors.warning,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildMetricsStats(
    BuildContext context,
    ThemeData theme,
    List<dynamic> metrics,
    dynamic profile,
  ) {
    if (metrics.isEmpty) {
      return _buildEmptyState('Sin medidas registradas');
    }

    final latest = metrics.first;
    final oldest = metrics.last;
    final weightChange = latest.weightKg - oldest.weightKg;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.monitor_weight_outlined,
                label: 'Peso Actual',
                value: '${latest.weightKg.toStringAsFixed(1)} kg',
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: weightChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                label: 'Cambio',
                value: '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                color: weightChange >= 0 ? AppColors.warning : AppColors.success,
              ),
            ),
          ],
        ),
        if (latest.bodyFatPercentage != null) ...[
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.water_drop_outlined,
            label: 'Grasa Corporal Actual',
            value: '${latest.bodyFatPercentage!.toStringAsFixed(1)}%',
            color: AppColors.info,
            isWide: true,
          ),
        ],
      ],
    );
  }

  Widget _buildRoutineStats(
    BuildContext context,
    ThemeData theme,
    List<dynamic> routines,
  ) {
    final active = routines.where((r) => !r.isArchived).toList();
    final archived = routines.where((r) => r.isArchived).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.list_alt,
                label: 'Activas',
                value: '${active.length}',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.archive_outlined,
                label: 'Archivadas',
                value: '${archived.length}',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isWide = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
    );
  }
}
