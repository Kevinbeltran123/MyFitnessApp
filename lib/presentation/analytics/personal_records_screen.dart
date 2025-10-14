import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';

class PersonalRecordsScreen extends ConsumerWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(personalRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Records personales')),
      body: recordsAsync.when(
        loading: () =>
            const LoadingStateWidget(message: 'Calculando tus PRs...'),
        error: (error, stackTrace) => ErrorStateWidget(
          title: 'No pudimos cargar tus records',
          message: error.toString(),
          onRetry: () => ref.invalidate(personalRecordsProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.emoji_events_outlined,
              title: 'Aún no tienes PRs registrados',
              message:
                  'Registra tus entrenamientos con peso y repeticiones para estimar tus records personales.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) =>
                _PersonalRecordTile(record: records[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: records.length,
          );
        },
      ),
    );
  }
}

class _PersonalRecordTile extends StatelessWidget {
  const _PersonalRecordTile({required this.record});

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = record.exerciseName?.trim().isNotEmpty == true
        ? record.exerciseName!.trim()
        : record.exerciseId;
    final date = record.achievedAt;
    final String dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.accentBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Logrado el $dateLabel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (record.setNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Set #${record.setNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${record.oneRepMax.toStringAsFixed(1)} kg',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '1RM estimado',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.veryLightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set marcado',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.bestWeight.toStringAsFixed(1)} kg × ${record.repetitions} rep${record.repetitions == 1 ? '' : 's'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sesión',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.sessionId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
