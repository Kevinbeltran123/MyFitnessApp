import 'package:flutter/material.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.muscles,
    required this.equipments,
    required this.selectedMuscles,
    required this.selectedEquipments,
    required this.onMuscleToggle,
    required this.onEquipmentToggle,
  });

  final List<String> muscles;
  final List<String> equipments;
  final Set<String> selectedMuscles;
  final Set<String> selectedEquipments;
  final ValueChanged<String> onMuscleToggle;
  final ValueChanged<String> onEquipmentToggle;

  @override
  Widget build(BuildContext context) {
    if (muscles.isEmpty && equipments.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          ..._buildSection(
            context,
            label: 'Músculos',
            values: muscles,
            selected: selectedMuscles,
            color: Theme.of(context).colorScheme.primaryContainer,
            onToggle: onMuscleToggle,
          ),
          if (muscles.isNotEmpty && equipments.isNotEmpty)
            const SizedBox(width: 12),
          ..._buildSection(
            context,
            label: 'Equipamiento',
            values: equipments,
            selected: selectedEquipments,
            color: Theme.of(context).colorScheme.secondaryContainer,
            onToggle: onEquipmentToggle,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSection(
    BuildContext context, {
    required String label,
    required List<String> values,
    required Set<String> selected,
    required Color color,
    required ValueChanged<String> onToggle,
  }) {
    if (values.isEmpty) {
      return <Widget>[];
    }

    final theme = Theme.of(context);
    return <Widget>[
      Text('$label:', style: theme.textTheme.labelLarge),
      const SizedBox(width: 8),
      ...values.map((String value) {
        final isSelected = selected.contains(value);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(_formatLabel(value)),
            selected: isSelected,
            onSelected: (_) => onToggle(value),
            selectedColor: color,
          ),
        );
      }),
    ];
  }
}

String _formatLabel(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value
      .split(' ')
      .where((String word) => word.isNotEmpty)
      .map((String word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
