import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_controller.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';
import 'package:my_fitness_tracker/presentation/analytics/widgets/frequency_insights.dart';
import 'package:my_fitness_tracker/presentation/analytics/widgets/muscle_distribution_insights.dart';
import 'package:my_fitness_tracker/presentation/analytics/widgets/volume_insights.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_dashboard_screen.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';

enum StatsRangePreset { last30Days, last90Days, last180Days }

extension StatsRangePresetX on StatsRangePreset {
  String get label {
    switch (this) {
      case StatsRangePreset.last30Days:
        return '30d';
      case StatsRangePreset.last90Days:
        return '90d';
      case StatsRangePreset.last180Days:
        return '180d';
    }
  }

  Duration get duration {
    switch (this) {
      case StatsRangePreset.last30Days:
        return const Duration(days: 30);
      case StatsRangePreset.last90Days:
        return const Duration(days: 90);
      case StatsRangePreset.last180Days:
        return const Duration(days: 180);
    }
  }
}

final statsRangePresetProvider = StateProvider<StatsRangePreset>(
  (ref) => StatsRangePreset.last90Days,
);

final statsRangeProvider = Provider<MetricDateRange>((ref) {
  final preset = ref.watch(statsRangePresetProvider);
  final DateTime now = DateTime.now();
  final DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final DateTime start = end
      .subtract(preset.duration)
      .add(const Duration(days: 1))
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  return MetricDateRange(start: start, end: end);
});

class StatsKpiData {
  const StatsKpiData({
    required this.totalSessions,
    required this.totalVolume,
    required this.currentStreak,
    required this.averageSessionsPerWeek,
  });

  final int totalSessions;
  final double totalVolume;
  final int currentStreak;
  final double averageSessionsPerWeek;
}

final statsKpiProvider = FutureProvider<StatsKpiData>((ref) async {
  final MetricDateRange range = ref.watch(statsRangeProvider);
  final WorkoutStats stats = await ref.watch(
    workoutStatsProvider(range).future,
  );
  final int days = range.end.difference(range.start).inDays + 1;
  final TrainingHeatmapParams params = TrainingHeatmapParams(
    anchor: range.end,
    days: days,
  );
  final TrainingHeatmapData heatmap = await ref.watch(
    trainingHeatmapProvider(params).future,
  );

  final double weeks = days / 7;
  final double averageSessionsPerWeek = weeks <= 0
      ? 0
      : stats.totalSessions / weeks;

  return StatsKpiData(
    totalSessions: stats.totalSessions,
    totalVolume: stats.totalVolume,
    currentStreak: heatmap.currentStreak,
    averageSessionsPerWeek: averageSessionsPerWeek,
  );
});

class StatInsight {
  const StatInsight({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
}

final statsInsightsProvider = FutureProvider<List<StatInsight>>((ref) async {
  final MetricDateRange range = ref.watch(statsRangeProvider);
  final int days = range.end.difference(range.start).inDays + 1;
  final DateTime previousEnd = range.start.subtract(const Duration(days: 1));
  final DateTime previousStart = previousEnd
      .subtract(Duration(days: days - 1))
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  final MetricDateRange previousRange = MetricDateRange(
    start: previousStart,
    end: previousEnd,
  );

  final WorkoutStats currentStats = await ref.watch(
    workoutStatsProvider(range).future,
  );
  final WorkoutStats previousStats = await ref.watch(
    workoutStatsProvider(previousRange).future,
  );
  final MuscleDistributionSummary muscleSummary = await ref.watch(
    muscleDistributionProvider(range).future,
  );
  final TrainingHeatmapData heatmap = await ref.watch(
    trainingHeatmapProvider(
      TrainingHeatmapParams(anchor: range.end, days: days),
    ).future,
  );
  final List<PersonalRecord> personalRecords = await ref.watch(
    personalRecordsProvider.future,
  );

  final List<StatInsight> insights = <StatInsight>[];

  // Volume trend insight
  final double previousVolume = previousStats.totalVolume;
  final double currentVolume = currentStats.totalVolume;
  if (previousVolume > 0 && currentVolume > 0) {
    final double delta =
        ((currentVolume - previousVolume) / previousVolume) * 100;
    final String trend = delta >= 0 ? 'incrementaste' : 'disminuiste';
    insights.add(
      StatInsight(
        icon: Icons.trending_up,
        color: delta >= 0 ? AppColors.success : AppColors.warning,
        title: 'Tendencia de volumen',
        message:
            'En este periodo $trend tu volumen ${delta.abs().toStringAsFixed(1)}%.',
      ),
    );
  } else if (currentVolume > 0) {
    insights.add(
      const StatInsight(
        icon: Icons.flag_circle_outlined,
        color: AppColors.accentBlue,
        title: 'Buen comienzo',
        message:
            'Has comenzado a registrar tu volumen. Sigue así para ver tendencias.',
      ),
    );
  }

  // Dominant muscle insight
  if (muscleSummary.dominantGroup != null) {
    insights.add(
      StatInsight(
        icon: Icons.fitness_center,
        color: AppColors.info,
        title: 'Grupo más trabajado',
        message:
            'Tu grupo más entrenado fue ${muscleSummary.dominantGroup!.group} con ${muscleSummary.dominantGroup!.percentage.toStringAsFixed(1)}% del volumen.',
      ),
    );
  }

  // Current streak insight
  insights.add(
    StatInsight(
      icon: Icons.local_fire_department_outlined,
      color: AppColors.success,
      title: 'Racha activa',
      message: heatmap.currentStreak > 0
          ? 'Llevas ${heatmap.currentStreak} días consecutivos entrenando.'
          : 'Aún no tienes una racha activa. ¡Hoy es un gran día para empezar!',
    ),
  );

  // Personal record insight (bench press if available)
  PersonalRecord? benchRecord;
  try {
    benchRecord = personalRecords.firstWhere(
      (record) => record.exerciseId == 'bench-press',
    );
  } catch (_) {
    benchRecord = null;
  }

  if (benchRecord != null &&
      benchRecord.oneRepMax > 0 &&
      benchRecord.achievedAt.isAfter(range.start)) {
    insights.add(
      StatInsight(
        icon: Icons.emoji_events_outlined,
        color: AppColors.warning,
        title: 'Nuevo récord en press banca',
        message:
            'Alcanzaste ${benchRecord.oneRepMax.toStringAsFixed(1)} kg estimados de 1RM el ${_formatDate(benchRecord.achievedAt)}.',
      ),
    );
  } else {
    insights.add(
      const StatInsight(
        icon: Icons.insights_outlined,
        color: AppColors.textSecondary,
        title: 'Registra tus records',
        message:
            'Marca tus sets pesados para detectar nuevos récords personales.',
      ),
    );
  }

  return insights;
});

/// Comprehensive statistics screen showing all fitness data grouped by tabs.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: _StatsAppBar(),
        body: TabBarView(
          children: [
            _GeneralStatsTab(),
            _VolumeStatsTab(),
            _DistributionStatsTab(),
            _FrequencyStatsTab(),
          ],
        ),
      ),
    );
  }
}

class _StatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _StatsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Estadísticas'),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Column(
          children: [
            SizedBox(height: 12),
            _StatsRangeSelector(),
            SizedBox(height: 12),
            TabBar(
              tabs: [
                Tab(text: 'General'),
                Tab(text: 'Volumen'),
                Tab(text: 'Distribución'),
                Tab(text: 'Frecuencia'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRangeSelector extends ConsumerWidget {
  const _StatsRangeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(statsRangePresetProvider);
    return SegmentedButton<StatsRangePreset>(
      segments: StatsRangePreset.values
          .map(
            (preset) => ButtonSegment<StatsRangePreset>(
              value: preset,
              label: Text(preset.label),
            ),
          )
          .toList(growable: false),
      selected: <StatsRangePreset>{preset},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          ref.read(statsRangePresetProvider.notifier).state = selection.first;
        }
      },
    );
  }
}

class _GeneralStatsTab extends ConsumerWidget {
  const _GeneralStatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(workoutHistoryControllerProvider);
    final routinesAsync = ref.watch(routineListControllerProvider);
    final metricsAsync = ref.watch(bodyMetricsProvider);
    final profileAsync = ref.watch(metabolicProfileProvider);
    final statsKpiAsync = ref.watch(statsKpiProvider);
    final insightsAsync = ref.watch(statsInsightsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(workoutHistoryControllerProvider);
        ref.invalidate(routineListControllerProvider);
        ref.invalidate(bodyMetricsProvider);
        ref.invalidate(statsKpiProvider);
        ref.invalidate(statsInsightsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          statsKpiAsync.when(
            data: (data) => _KpiRow(data: data),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          insightsAsync.when(
            data: (insights) => _InsightsList(insights: insights),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          sessionsAsync.when(
            data: (sessions) => _OverviewCard(
              sessions: sessions,
              routines: routinesAsync.value ?? [],
              metrics: metricsAsync.value ?? [],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Entrenamientos'),
          const SizedBox(height: 12),
          sessionsAsync.when(
            data: (sessions) => _WorkoutStatsSection(sessions: sessions),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Progreso corporal'),
          const SizedBox(height: 12),
          metricsAsync.when(
            data: (metrics) => _MetricsStatsSection(
              metrics: metrics,
              profile: profileAsync.value,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Rutinas'),
          const SizedBox(height: 12),
          routinesAsync.when(
            data: (routines) => _RoutineStatsSection(routines: routines),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _VolumeStatsTab extends ConsumerWidget {
  const _VolumeStatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(statsRangeProvider);
    return VolumeInsights(range: range);
  }
}

class _DistributionStatsTab extends ConsumerWidget {
  const _DistributionStatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(statsRangeProvider);
    return MuscleDistributionInsights(range: range);
  }
}

class _FrequencyStatsTab extends ConsumerWidget {
  const _FrequencyStatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(statsRangeProvider);
    return FrequencyInsights(range: range);
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.data});

  final StatsKpiData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center,
            label: 'Entrenamientos',
            value: '${data.totalSessions}',
            color: AppColors.accentBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up,
            label: 'Volumen total',
            value: '${data.totalVolume.toStringAsFixed(0)} kg',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            label: 'Racha actual',
            value: '${data.currentStreak} días',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_view_week,
            label: 'Sesiones/sem',
            value: data.averageSessionsPerWeek.toStringAsFixed(1),
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _InsightsList extends StatelessWidget {
  const _InsightsList({required this.insights});

  final List<StatInsight> insights;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.psychology_outlined,
        title: 'Aún no hay insights',
        message: 'Registra entrenamientos para obtener recomendaciones útiles.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: insights
          .map((insight) => _InsightCard(insight: insight))
          .toList(growable: false),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final StatInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(insight.icon, color: insight.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.sessions,
    required this.routines,
    required this.metrics,
  });

  final List<dynamic> sessions;
  final List<dynamic> routines;
  final List<dynamic> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
              const Icon(Icons.insights, color: AppColors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Resumen general',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: 'Entrenamientos',
                  value: '${sessions.length}',
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Rutinas activas',
                  value: '${routines.where((r) => !r.isArchived).length}',
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Medidas registradas',
                  value: '${metrics.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _WorkoutStatsSection extends StatelessWidget {
  const _WorkoutStatsSection({required this.sessions});

  final List<dynamic> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.fitness_center_outlined,
        title: 'Sin entrenamientos registrados',
        message: 'Registra tus sesiones para ver estadísticas detalladas.',
      );
    }

    final Duration totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.completedAt.difference(session.startedAt),
    );
    final int totalSets = sessions.fold<int>(0, (sum, session) {
      final int sessionSets = session.exerciseLogs.fold<int>(
        0,
        (inner, log) => inner + log.setLogs.length,
      );
      return sum + sessionSets;
    });
    final double totalVolume = sessions.fold<double>(
      0,
      (sum, session) =>
          sum +
          session.exerciseLogs.fold<double>(
            0,
            (s, log) =>
                s +
                log.setLogs.fold<double>(
                  0,
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
                label: 'Tiempo total',
                value:
                    '${totalDuration.inHours}h ${totalDuration.inMinutes.remainder(60)}m',
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.repeat,
                label: 'Series totales',
                value: '$totalSets',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.trending_up,
          label: 'Volumen total',
          value: '${totalVolume.toStringAsFixed(0)} kg',
          color: AppColors.warning,
          isWide: true,
        ),
      ],
    );
  }
}

class _MetricsStatsSection extends StatelessWidget {
  const _MetricsStatsSection({required this.metrics, required this.profile});

  final List<dynamic> metrics;
  final dynamic profile;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.monitor_weight_outlined,
        title: 'Sin medidas registradas',
        message: 'Añade tus mediciones corporales para seguir tu progreso.',
      );
    }

    final latest = metrics.first;
    final oldest = metrics.last;
    final double weightChange = latest.weightKg - oldest.weightKg;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.monitor_weight_outlined,
                label: 'Peso actual',
                value: '${latest.weightKg.toStringAsFixed(1)} kg',
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: weightChange >= 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                label: 'Cambio',
                value:
                    '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                color: weightChange >= 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
          ],
        ),
        if (latest.bodyFatPercentage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _StatCard(
              icon: Icons.water_drop_outlined,
              label: 'Grasa corporal',
              value: '${latest.bodyFatPercentage!.toStringAsFixed(1)}%',
              color: AppColors.info,
              isWide: true,
            ),
          ),
        if (profile != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MetricsDashboardScreen(),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Ver métricas detalladas'),
          ),
      ],
    );
  }
}

class _RoutineStatsSection extends StatelessWidget {
  const _RoutineStatsSection({required this.routines});

  final List<dynamic> routines;

  @override
  Widget build(BuildContext context) {
    if (routines.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.list_alt_outlined,
        title: 'No tienes rutinas creadas',
        message: 'Crea tu primera rutina para ver estadísticas aquí.',
      );
    }

    final active = routines.where((routine) => !routine.isArchived).toList();
    final archived = routines.where((routine) => routine.isArchived).toList();

    return Row(
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
    final Widget iconWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );

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
                iconWidget,
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
                iconWidget,
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

String _formatDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String year = date.year.toString();
  return '$day/$month/$year';
}
