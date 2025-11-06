import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/shared/services/haptic_service.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';
import 'package:uuid/uuid.dart';

Future<double?> showQuickWeightLoggerDialog(
  BuildContext context,
  WidgetRef ref,
) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(context) + const EdgeInsets.all(16),
        child: _QuickWeightLoggerSheet(ref: ref),
      );
    },
  );
}

class _QuickWeightLoggerSheet extends ConsumerStatefulWidget {
  const _QuickWeightLoggerSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_QuickWeightLoggerSheet> createState() => _QuickWeightLoggerSheetState();
}

class _QuickWeightLoggerSheetState extends ConsumerState<_QuickWeightLoggerSheet> {
  final TextEditingController _weightController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialWeight();
  }

  Future<void> _loadInitialWeight() async {
    final repository = await widget.ref.read(metricsRepositoryProvider.future);
    final latest = await repository.latestMetric();
    final double suggestion = latest?.weightKg ?? 70;
    _weightController.text = suggestion.toStringAsFixed(1);
  }

  Future<void> _save() async {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    if (weight == null || weight <= 0) {
      AppSnackBar.showError(context, 'Ingresa un peso válido.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = await widget.ref.read(metricsRepositoryProvider.future);
      final metric = BodyMetric(
        id: const Uuid().v4(),
        recordedAt: DateTime.now(),
        weightKg: weight,
        bodyFatPercentage: null,
        muscleMassKg: null,
        notes: null,
        measurements: const <String, double>{},
      );
      await repository.upsertMetric(metric);
      await widget.ref.read(hapticServiceProvider).medium();
      if (!mounted) return;
      Navigator.of(context).pop(weight);
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'No pudimos guardar el peso: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _adjust(double delta) {
    final current = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0;
    final next = (current + delta).clamp(20, 300);
    setState(() {
      _weightController.text = next.toStringAsFixed(1);
    });
    unawaited(widget.ref.read(hapticServiceProvider).light());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registrar peso rápido',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Se guardará con la fecha y hora actuales.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _AdjustButton(icon: Icons.remove, onTap: () => _adjust(-0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.veryLightGray,
                      suffixText: 'kg',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _AdjustButton(icon: Icons.add, onTap: () => _adjust(0.5)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Guardando...' : 'Guardar peso'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightGray,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
      ),
    );
  }
}
