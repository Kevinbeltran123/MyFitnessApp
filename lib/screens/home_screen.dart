import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/presentation/achievements/achievements_screen.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_screen.dart';
import 'package:my_fitness_tracker/presentation/home/home_controller.dart';
import 'package:my_fitness_tracker/presentation/home/widgets/home_hero_section.dart';
import 'package:my_fitness_tracker/presentation/home/widgets/home_quick_stats.dart';
import 'package:my_fitness_tracker/presentation/home/widgets/mini_progress_chart.dart';
import 'package:my_fitness_tracker/presentation/home/widgets/quick_actions_grid.dart';
import 'package:my_fitness_tracker/presentation/home/widgets/recent_achievements.dart';
import 'package:my_fitness_tracker/presentation/home/widgets/weekly_routine_calendar.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/quick_weight_logger_dialog.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_screen.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_session_screen.dart';
import 'package:my_fitness_tracker/shared/services/notification_service.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _refreshDashboard() async {
    final _ = await ref.refresh(homeDashboardProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final notificationService = ref.read(notificationServiceProvider);
    final AsyncValue<HomeDashboardState> dashboard = ref.watch(
      homeDashboardProvider,
    );

    final Widget fab = FloatingActionButton.extended(
      onPressed: () async {
        final result = await showQuickWeightLoggerDialog(context, ref);
        if (!context.mounted || result == null) return;
        AppSnackBar.showSuccess(
          context,
          'Peso registrado: ${result.toStringAsFixed(1)} kg',
        );
        await _refreshDashboard();
      },
      tooltip:
          'Toca para registrar, mantén presionado para crear acceso rápido',
      icon: const Icon(Icons.monitor_weight_outlined),
      label: const Text('Peso rápido'),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: GestureDetector(
        onLongPress: () async {
          final bool created = await notificationService
              .showQuickWeightShortcut();
          if (!context.mounted) return;
          if (created) {
            AppSnackBar.showInfo(
              context,
              'Notificación creada. Tócala para registrar peso.',
            );
          } else {
            AppSnackBar.showWarning(
              context,
              'Activa las notificaciones para usar el acceso rápido.',
            );
          }
        },
        child: fab,
      ),
      body: SafeArea(
        child: dashboard.when(
          data: (state) => RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                HomeHeroSection(
                  state: state,
                  onStartRoutine: state.nextRoutine == null
                      ? null
                      : () => _startRoutine(state.nextRoutine!),
                ),
                const SizedBox(height: 24),
                HomeQuickStats(stats: state.quickStats),
                if (state.hasSparkline) ...[
                  const SizedBox(height: 24),
                  MiniProgressChart(points: state.sparkline),
                ],
                const SizedBox(height: 24),
                QuickActionsGrid(
                  onStartWorkout: _openRoutineList,
                  onLogWeight: () async {
                    final result = await showQuickWeightLoggerDialog(
                      context,
                      ref,
                    );
                    if (!context.mounted || result == null) return;
                    AppSnackBar.showSuccess(
                      context,
                      'Peso registrado: ${result.toStringAsFixed(1)} kg',
                    );
                    await _refreshDashboard();
                  },
                  onViewProgress: _openAnalytics,
                ),
                const SizedBox(height: 24),
                Text(
                  'Calendario semanal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                WeeklyRoutineCalendar(
                  days: state.calendar,
                  onDaySelected: _onCalendarDaySelected,
                ),
                const SizedBox(height: 32),
                RecentAchievementsSection(
                  achievements: state.recentAchievements,
                  onViewAll: _openAchievements,
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              _HomeErrorView(error: error, onRetry: _refreshDashboard),
        ),
      ),
    );
  }

  Future<void> _startRoutine(RoutineSummary summary) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoutineSessionScreen(routineId: summary.routineId),
      ),
    );
    if (!mounted) return;
    await _refreshDashboard();
  }

  void _openRoutineList() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RoutineListScreen()));
  }

  void _openAnalytics() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()));
  }

  void _openAchievements() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AchievementsScreen()));
  }

  Future<void> _onCalendarDaySelected(HomeCalendarDay day) async {
    if (day.scheduledRoutines.isEmpty) {
      return;
    }
    if (day.scheduledRoutines.length == 1) {
      await _startRoutine(day.scheduledRoutines.first);
      return;
    }

    final RoutineSummary? selected = await showModalBottomSheet<RoutineSummary>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecciona una rutina',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              for (final RoutineSummary summary in day.scheduledRoutines)
                ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(summary.name),
                  subtitle: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatFullDate(summary.nextOccurrence),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(summary),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await _startRoutine(selected);
    }
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'No pudimos actualizar tu dashboard.\n$error',
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
