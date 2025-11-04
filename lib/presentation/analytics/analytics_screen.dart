import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/presentation/analytics/widgets/muscle_distribution_insights.dart';
import 'package:my_fitness_tracker/presentation/analytics/widgets/volume_insights.dart';

/// Centralised analytics screen showcasing advanced workout insights.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _AnalyticsAppBar(),
        body: TabBarView(
          children: [
            VolumeInsights(),
            MuscleDistributionInsights(),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AnalyticsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(98);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Analytics'),
      bottom: const TabBar(
        tabs: [
          Tab(text: 'Volumen'),
          Tab(text: 'Distribución'),
        ],
      ),
    );
  }
}
