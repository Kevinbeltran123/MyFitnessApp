import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/application/gamification/streak_tracker.dart';
import 'package:my_fitness_tracker/domain/gamification/achievement_entities.dart';
import 'package:my_fitness_tracker/presentation/achievements/achievements_providers.dart';
import 'package:my_fitness_tracker/presentation/achievements/achievements_screen.dart';
import 'package:my_fitness_tracker/presentation/achievements/widgets/streak_counter.dart';
import 'package:my_fitness_tracker/presentation/achievements/widgets/achievement_badge.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_screen.dart';
import 'package:my_fitness_tracker/presentation/analytics/personal_records_screen.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_dashboard_screen.dart';
import 'package:my_fitness_tracker/presentation/profile/profile_image_controller.dart';
import 'package:my_fitness_tracker/presentation/profile/settings_screen.dart';
import 'package:my_fitness_tracker/presentation/profile/statistics_screen.dart';
import 'package:my_fitness_tracker/presentation/profile/widgets/profile_image_picker.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';

/// Profile and More screen.
///
/// Central hub for:
/// - User profile management
/// - Statistics overview
/// - Access to Medidas (metrics)
/// - App settings
/// - About/Help
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(workoutHistoryControllerProvider);
    final metricsAsync = ref.watch(bodyMetricsProvider);
    final personalRecordsAsync = ref.watch(personalRecordsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final highlightId = ref.watch(latestUnlockedAchievementProvider);
    final bool hasPersonalRecords = personalRecordsAsync.maybeWhen(
      data: (records) => records.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Más')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile header
              const _ProfileHeader(),
              const SizedBox(height: 24),

              // Quick stats
              _buildQuickStats(
                context,
                theme,
                sessionsAsync.value?.length ?? 0,
                metricsAsync.value?.length ?? 0,
              ),
              const SizedBox(height: 24),

              achievementsAsync.when(
                data: (achievements) => achievements.isEmpty
                    ? const SizedBox.shrink()
                    : _AchievementsPreview(
                        achievements: achievements,
                        streak: streakAsync.valueOrNull,
                        highlightedId: highlightId,
                        onViewAll: () => _navigateToAchievements(context),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              if (achievementsAsync.asData?.value.isNotEmpty == true)
                const SizedBox(height: 24),

              streakAsync.when(
                data: (snapshot) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: StreakCounter(snapshot: snapshot, daysToDisplay: 7),
                ),
                loading: () => const SizedBox(height: 24),
                error: (_, __) => const SizedBox(height: 24),
              ),

              personalRecordsAsync.when(
                data: (records) => records.isEmpty
                    ? const SizedBox.shrink()
                    : _PersonalRecordsCard(
                        records: records.take(3).toList(growable: false),
                        onViewAll: () => _navigateToPersonalRecords(context),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              if (hasPersonalRecords) const SizedBox(height: 24),

              // Main actions
              Text(
                'Principal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              _MenuCard(
                icon: Icons.monitor_weight_outlined,
                iconColor: AppColors.accentBlue,
                title: 'Medidas Corporales',
                subtitle: 'Peso, grasa corporal, IMC',
                onTap: () => _navigateToMetrics(context),
              ),
              const SizedBox(height: 8),

              _MenuCard(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.success,
                title: 'Estadísticas',
                subtitle: 'Progreso y análisis completo',
                onTap: () => _navigateToStatistics(context),
              ),
              const SizedBox(height: 8),

              _MenuCard(
                icon: Icons.query_stats_outlined,
                iconColor: AppColors.info,
                title: 'Analytics',
                subtitle: 'Volumen, distribuciones y comparativas',
                onTap: () => _navigateToAnalytics(context),
              ),
              const SizedBox(height: 8),

              _MenuCard(
                icon: Icons.emoji_events_outlined,
                iconColor: AppColors.warning,
                title: 'Logros',
                subtitle: 'Revisa tus badges y rachas',
                onTap: () => _navigateToAchievements(context),
              ),
              const SizedBox(height: 24),

              // Settings section
              Text(
                'Configuración',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              _MenuCard(
                icon: Icons.settings_outlined,
                iconColor: AppColors.mediumGray,
                title: 'Ajustes',
                subtitle: 'Notificaciones, unidades, idioma',
                onTap: () => _navigateToSettings(context),
              ),
              const SizedBox(height: 8),

              _MenuCard(
                icon: Icons.person_outline,
                iconColor: AppColors.mediumGray,
                title: 'Perfil',
                subtitle: 'Información personal',
                onTap: () => _showComingSoon(context, 'Perfil'),
              ),
              const SizedBox(height: 24),

              // Help & About section
              Text(
                'Ayuda',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              _MenuCard(
                icon: Icons.help_outline,
                iconColor: AppColors.info,
                title: 'Ayuda y Soporte',
                subtitle: 'FAQs, contacto',
                onTap: () => _showComingSoon(context, 'Ayuda'),
              ),
              const SizedBox(height: 8),

              _MenuCard(
                icon: Icons.info_outline,
                iconColor: AppColors.info,
                title: 'Acerca de',
                subtitle: 'Versión 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              const SizedBox(height: 32),

              // App info footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'My Fitness Tracker',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Versión 1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    ThemeData theme,
    int workoutCount,
    int metricCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center,
            label: 'Entrenamientos',
            value: '$workoutCount',
            color: AppColors.accentBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.monitor_weight_outlined,
            label: 'Medidas',
            value: '$metricCount',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  void _navigateToMetrics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MetricsDashboardScreen()),
    );
  }

  void _navigateToPersonalRecords(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PersonalRecordsScreen()),
    );
  }

  void _navigateToStatistics(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const StatisticsScreen()));
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AchievementsScreen()));
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _showComingSoon(BuildContext context, String feature) {
    AppSnackBar.showInfo(context, '$feature estará disponible próximamente');
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'My Fitness Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          gradient: AppColors.grayGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.fitness_center,
          color: AppColors.white,
          size: 30,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Tu compañero personal para seguimiento de ejercicios, rutinas y progreso físico.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Desarrollado con Flutter y diseñado con amor para ayudarte a alcanzar tus metas fitness.',
        ),
      ],
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(metabolicProfileProvider);
    final profileImagePath = ref.watch(profileImagePathProvider);
    final profile = profileAsync.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.grayGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with ProfileImagePicker
          ProfileImagePicker(
            imagePath: profileImagePath,
            onImageSelected: (newPath) => ref
                .read(profileImagePathProvider.notifier)
                .updateImage(profile: profile, newPath: newPath),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            'Usuario',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          // Quick info
          if (profile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${profile.heightCm.toStringAsFixed(0)} cm • ${profile.age} años',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsPreview extends StatelessWidget {
  const _AchievementsPreview({
    required this.achievements,
    required this.streak,
    required this.highlightedId,
    required this.onViewAll,
  });

  final List<Achievement> achievements;
  final StreakSnapshot? streak;
  final String? highlightedId;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Achievement> sorted = [...achievements]
      ..sort((a, b) => b.progress().compareTo(a.progress()));
    final preview = sorted.take(3).toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.15),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Logros',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: onViewAll, child: const Text('Ver todos')),
            ],
          ),
          if (streak != null) ...[
            const SizedBox(height: 4),
            Text(
              'Racha actual: ${streak!.currentStreak} días',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: preview
                .map(
                  (achievement) => AchievementBadge(
                    achievement: achievement,
                    showProgress: true,
                    highlight: highlightedId == achievement.id,
                    size: 64,
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _globalProgress(preview),
            minHeight: 6,
            backgroundColor: AppColors.veryLightGray,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.accentBlue,
            ),
          ),
        ],
      ),
    );
  }

  double _globalProgress(List<Achievement> preview) {
    if (preview.isEmpty) {
      return 0;
    }
    final double total = preview.fold<double>(
      0,
      (sum, item) => sum + item.progress(),
    );
    return (total / preview.length).clamp(0, 1);
  }
}

class _PersonalRecordsCard extends StatelessWidget {
  const _PersonalRecordsCard({required this.records, required this.onViewAll});

  final List<PersonalRecord> records;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.grayGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Records personales',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.white,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...records.indexed.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.$1 == records.length - 1 ? 0 : 12,
              ),
              child: _PersonalRecordRow(record: entry.$2),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalRecordRow extends StatelessWidget {
  const _PersonalRecordRow({required this.record});

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = record.exerciseName?.trim().isNotEmpty == true
        ? record.exerciseName!.trim()
        : record.exerciseId;
    final String subtitle =
        '${record.bestWeight.toStringAsFixed(1)} kg × ${record.repetitions} rep${record.repetitions == 1 ? '' : 's'}';
    final String dateLabel =
        '${record.achievedAt.day.toString().padLeft(2, '0')}/${record.achievedAt.month.toString().padLeft(2, '0')}/${record.achievedAt.year}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentBlue.withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.oneRepMax.toStringAsFixed(1)} kg',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '1RM estimado',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
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
