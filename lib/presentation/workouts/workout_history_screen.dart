import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';
import 'package:my_fitness_tracker/presentation/workouts/widgets/workout_session_card.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';

/// Workout history screen showing all completed training sessions.
///
/// Features:
/// - List of completed workout sessions
/// - Weekly/monthly progress charts
/// - Filter by date range
/// - Session details on tap
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  DateTimeRange? _selectedDateRange;

  void _showDateRangePicker() async {
    final now = DateTime.now();
    final initialRange =
        _selectedDateRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.accentBlue,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(workoutHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenamientos'),
        actions: [
          IconButton(
            icon: Icon(
              _selectedDateRange != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: _selectedDateRange != null
                  ? AppColors.accentBlue
                  : AppColors.textSecondary,
            ),
            onPressed: _showDateRangePicker,
            tooltip: 'Filtrar por fecha',
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilter,
              tooltip: 'Limpiar filtro',
            ),
        ],
      ),
      body: SafeArea(
        child: sessionsAsync.when(
          loading: () => const LoadingStateWidget(),
          error: (error, stack) => ErrorStateWidget(
            title: 'Error al cargar entrenamientos',
            message: error.toString(),
            onRetry: () => ref.invalidate(workoutHistoryControllerProvider),
          ),
          data: (sessions) => _buildContent(context, sessions, theme),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<RoutineSession> sessions,
    ThemeData theme,
  ) {
    // Filter sessions by date range if selected
    final filteredSessions = _selectedDateRange == null
        ? sessions
        : sessions.where((session) {
            return session.startedAt.isAfter(
                  _selectedDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                session.startedAt.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)),
                );
          }).toList();

    if (filteredSessions.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate summary stats
    final totalSessions = filteredSessions.length;
    final totalDuration = filteredSessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.completedAt.difference(session.startedAt),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(workoutHistoryControllerProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Summary header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.subtleGrayGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.textTertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.fitness_center,
                          label: 'Sesiones',
                          value: '$totalSessions',
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.timer_outlined,
                          label: 'Tiempo total',
                          value: _formatTotalDuration(totalDuration),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedDateRange != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 16,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Session list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final session = filteredSessions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey<String>('session-${session.id}'),
                    direction: DismissDirection.horizontal,
                    background: const _SessionSwipeBackground(
                      alignment: Alignment.centerLeft,
                      icon: Icons.visibility_outlined,
                      label: 'Ver detalles',
                    ),
                    secondaryBackground: const _SessionSwipeBackground(
                      alignment: Alignment.centerRight,
                      icon: Icons.visibility_outlined,
                      label: 'Ver detalles',
                    ),
                    confirmDismiss: (direction) async {
                      await showWorkoutSessionDetails(context, session);
                      return false;
                    },
                    child: WorkoutSessionCard(session: session),
                  ),
                );
              }, childCount: filteredSessions.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accentBlue),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
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

  Widget _buildEmptyState() {
    final bool hasFilter = _selectedDateRange != null;
    return EmptyStateWidget(
      icon: Icons.fitness_center_outlined,
      title: hasFilter
          ? 'No hay entrenamientos en este período'
          : 'Aún no tienes entrenamientos',
      message: hasFilter
          ? 'Prueba con un rango de fechas diferente para ver tus sesiones.'
          : 'Completa tu primera rutina para ver el historial aquí.',
      primaryLabel: hasFilter ? 'Mostrar todo' : null,
      onPrimaryTap: hasFilter ? _clearFilter : null,
    );
  }

  String _formatTotalDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SessionSwipeBackground extends StatelessWidget {
  const _SessionSwipeBackground({
    required this.alignment,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accentBlue),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
