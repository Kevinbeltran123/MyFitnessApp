import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_dashboard_screen.dart';
import 'package:my_fitness_tracker/presentation/profile/settings_screen.dart';
import 'package:my_fitness_tracker/presentation/profile/statistics_screen.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

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
    final profileAsync = ref.watch(metabolicProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Más'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile header
              _buildProfileHeader(context, theme, profileAsync.value),
              const SizedBox(height: 24),

              // Quick stats
              _buildQuickStats(
                context,
                theme,
                sessionsAsync.value?.length ?? 0,
                metricsAsync.value?.length ?? 0,
              ),
              const SizedBox(height: 24),

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

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    dynamic profile,
  ) {
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
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppColors.white,
            ),
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
      MaterialPageRoute(
        builder: (context) => const MetricsDashboardScreen(),
      ),
    );
  }

  void _navigateToStatistics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StatisticsScreen(),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: AppColors.info,
      ),
    );
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
        side: BorderSide(
          color: AppColors.textTertiary.withValues(alpha: 0.15),
        ),
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
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
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
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
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
