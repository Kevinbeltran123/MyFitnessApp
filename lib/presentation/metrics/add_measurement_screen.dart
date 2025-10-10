import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:uuid/uuid.dart';

/// Screen for adding a new body measurement.
class AddMeasurementScreen extends ConsumerStatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  ConsumerState<AddMeasurementScreen> createState() =>
      _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends ConsumerState<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _notesController = TextEditingController();

  // Optional measurements
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _armsController = TextEditingController();
  final _thighsController = TextEditingController();

  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _notesController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _armsController.dispose();
    _thighsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = await ref.read(metricsRepositoryProvider.future);

      // Build measurements map
      final measurements = <String, double>{};
      if (_waistController.text.isNotEmpty) {
        measurements['cintura'] = double.parse(_waistController.text);
      }
      if (_chestController.text.isNotEmpty) {
        measurements['pecho'] = double.parse(_chestController.text);
      }
      if (_armsController.text.isNotEmpty) {
        measurements['brazos'] = double.parse(_armsController.text);
      }
      if (_thighsController.text.isNotEmpty) {
        measurements['muslos'] = double.parse(_thighsController.text);
      }

      final metric = BodyMetric(
        id: const Uuid().v4(),
        recordedAt: _selectedDate,
        weightKg: double.parse(_weightController.text),
        bodyFatPercentage: _bodyFatController.text.isNotEmpty
            ? double.parse(_bodyFatController.text)
            : null,
        muscleMassKg: _muscleMassController.text.isNotEmpty
            ? double.parse(_muscleMassController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        measurements: measurements,
      );

      await repository.upsertMetric(metric);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medida guardada exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Medida'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveMeasurement,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(_selectedDate),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Cambiar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Required measurements section
              Text(
                'Medidas Principales',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Weight (required)
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg) *',
                  hintText: '70.5',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El peso es requerido';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Ingresa un peso válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Body fat percentage (optional)
              TextFormField(
                controller: _bodyFatController,
                decoration: const InputDecoration(
                  labelText: 'Grasa Corporal (%)',
                  hintText: '18.5',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final fat = double.tryParse(value);
                    if (fat == null || fat < 0 || fat > 100) {
                      return 'Ingresa un porcentaje válido (0-100)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Muscle mass (optional)
              TextFormField(
                controller: _muscleMassController,
                decoration: const InputDecoration(
                  labelText: 'Masa Muscular (kg)',
                  hintText: '55.0',
                  prefixIcon: Icon(Icons.fitness_center_outlined),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final muscle = double.tryParse(value);
                    if (muscle == null || muscle <= 0) {
                      return 'Ingresa una masa válida';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Optional circumference measurements
              Text(
                'Medidas Adicionales (Opcional)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Medidas de circunferencia en centímetros',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _waistController,
                      decoration: const InputDecoration(
                        labelText: 'Cintura (cm)',
                        hintText: '85',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _chestController,
                      decoration: const InputDecoration(
                        labelText: 'Pecho (cm)',
                        hintText: '95',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _armsController,
                      decoration: const InputDecoration(
                        labelText: 'Brazos (cm)',
                        hintText: '32',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _thighsController,
                      decoration: const InputDecoration(
                        labelText: 'Muslos (cm)',
                        hintText: '55',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Notes
              Text(
                'Notas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
                  hintText: 'Sensaciones, condiciones, etc.',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 32),

              // Save button
              FilledButton.icon(
                onPressed: _isLoading ? null : _saveMeasurement,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Guardando...' : 'Guardar Medida'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
