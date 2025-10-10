import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Chip-based selector to choose the active metric range preset.
class MetricRangeSelector extends ConsumerWidget {
  const MetricRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMetricRangeProvider);
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: MetricRangePreset.values.map((preset) {
        final bool isSelected = preset == selected;
        return ChoiceChip(
          selected: isSelected,
          showCheckmark: false,
          label: Text(
            preset.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          selectedColor: AppColors.accentBlue,
          backgroundColor: AppColors.lightGray,
          onSelected: (_) =>
              ref.read(selectedMetricRangeProvider.notifier).state = preset,
        );
      }).toList(),
    );
  }
}
