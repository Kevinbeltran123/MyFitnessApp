import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';
import 'package:my_fitness_tracker/shared/widgets/numeric_input_field.dart';
import 'package:uuid/uuid.dart';

/// Screen for adding a new body measurement.
class AddMeasurementScreen extends ConsumerStatefulWidget {
  const AddMeasurementScreen({super.key, this.initialMetric});

  final BodyMetric? initialMetric;

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
  late bool _isEditing;
  late DateTime _selectedDate;

  BodyMetric? get _initialMetric => widget.initialMetric;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialMetric != null;
    _selectedDate = widget.initialMetric?.recordedAt ?? DateTime.now();
    if (_isEditing) {
      _populateFromMetric(widget.initialMetric!);
    }
  }

  void _populateFromMetric(BodyMetric metric) {
    _weightController.text = metric.weightKg.toStringAsFixed(1);
    if (metric.bodyFatPercentage != null) {
      _bodyFatController.text = metric.bodyFatPercentage!.toStringAsFixed(1);
    }
    if (metric.muscleMassKg != null) {
      _muscleMassController.text = metric.muscleMassKg!.toStringAsFixed(1);
    }
    if (metric.notes?.isNotEmpty == true) {
      _notesController.text = metric.notes!;
    }
    _waistController.text = metric.measurements['cintura']?.toString() ?? '';
    _chestController.text = metric.measurements['pecho']?.toString() ?? '';
    _armsController.text = metric.measurements['brazos']?.toString() ?? '';
    _thighsController.text = metric.measurements['muslos']?.toString() ?? '';
  }

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

  DateTime get _now => DateTime.now();

  DateTime get _twoYearsAgo {
    final DateTime now = _now;
    return DateTime(now.year - 2, now.month, now.day);
  }

  double _parseNumber(String value) => double.parse(value.replaceAll(',', '.'));

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _twoYearsAgo,
      lastDate: _now,
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

    final DateTime now = _now;
    final DateTime earliest = _twoYearsAgo;
    if (_selectedDate.isAfter(now)) {
      AppSnackBar.showError(context, 'La fecha no puede ser futura.');
      return;
    }
    if (_selectedDate.isBefore(earliest)) {
      AppSnackBar.showError(
        context,
        'Solo puedes registrar medidas de los últimos 2 años.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = await ref.read(metricsRepositoryProvider.future);

      final Map<String, double> measurements = Map<String, double>.from(
        _initialMetric?.measurements ?? <String, double>{},
      );

      void updateMeasurement(String key, TextEditingController controller) {
        if (controller.text.isNotEmpty) {
          measurements[key] = _parseNumber(controller.text);
        } else {
          measurements.remove(key);
        }
      }

      updateMeasurement('cintura', _waistController);
      updateMeasurement('pecho', _chestController);
      updateMeasurement('brazos', _armsController);
      updateMeasurement('muslos', _thighsController);

      final metric = BodyMetric(
        id: _isEditing ? _initialMetric!.id : const Uuid().v4(),
        recordedAt: _selectedDate,
        weightKg: _parseNumber(_weightController.text),
        bodyFatPercentage: _bodyFatController.text.isNotEmpty
            ? _parseNumber(_bodyFatController.text)
            : null,
        muscleMassKg: _muscleMassController.text.isNotEmpty
            ? _parseNumber(_muscleMassController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        measurements: measurements,
      );

      await repository.upsertMetric(metric);

      if (!mounted) return;

      AppSnackBar.showSuccess(
        context,
        _isEditing ? 'Medida actualizada' : 'Medida guardada exitosamente',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      AppSnackBar.showError(context, 'Error al guardar: $error');
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
        title: Text(_isEditing ? 'Editar Medida' : 'Nueva Medida'),
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
              NumericInputField(
                controller: _weightController,
                labelText: 'Peso (kg) *',
                hintText: '70.5',
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                decimal: true,
                decimalDigits: 1,
                initialStep: 0.5,
                min: 20,
                max: 300,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El peso es requerido';
                  }
                  final double? weight = double.tryParse(
                    value.replaceAll(',', '.'),
                  );
                  if (weight == null) {
                    return 'Ingresa un número válido';
                  }
                  if (weight < 20 || weight > 300) {
                    return 'Usa un rango entre 20 y 300 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Body fat percentage (optional)
              NumericInputField(
                controller: _bodyFatController,
                labelText: 'Grasa Corporal (%)',
                hintText: '18.5',
                prefixIcon: const Icon(Icons.water_drop_outlined),
                decimal: true,
                decimalDigits: 1,
                initialStep: 0.5,
                min: 1,
                max: 70,
                allowEmpty: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final double? fat = double.tryParse(
                      value.replaceAll(',', '.'),
                    );
                    if (fat == null) {
                      return 'Ingresa un número válido';
                    }
                    if (fat < 1 || fat > 70) {
                      return 'Ingresa un porcentaje entre 1% y 70%';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Muscle mass (optional)
              NumericInputField(
                controller: _muscleMassController,
                labelText: 'Masa Muscular (kg)',
                hintText: '55.0',
                prefixIcon: const Icon(Icons.fitness_center_outlined),
                decimal: true,
                decimalDigits: 1,
                initialStep: 0.5,
                min: 1,
                max: 150,
                allowEmpty: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final double? muscle = double.tryParse(
                      value.replaceAll(',', '.'),
                    );
                    if (muscle == null) {
                      return 'Ingresa un número válido';
                    }
                    if (muscle < 1 || muscle > 150) {
                      return 'Usa un rango entre 1 y 150 kg';
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
                    child: NumericInputField(
                      controller: _waistController,
                      labelText: 'Cintura (cm)',
                      hintText: '85',
                      decimal: true,
                      decimalDigits: 1,
                      initialStep: 1,
                      min: 0,
                      allowEmpty: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumericInputField(
                      controller: _chestController,
                      labelText: 'Pecho (cm)',
                      hintText: '95',
                      decimal: true,
                      decimalDigits: 1,
                      initialStep: 1,
                      min: 0,
                      allowEmpty: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: NumericInputField(
                      controller: _armsController,
                      labelText: 'Brazos (cm)',
                      hintText: '32',
                      decimal: true,
                      decimalDigits: 1,
                      initialStep: 1,
                      min: 0,
                      allowEmpty: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumericInputField(
                      controller: _thighsController,
                      labelText: 'Muslos (cm)',
                      hintText: '55',
                      decimal: true,
                      decimalDigits: 1,
                      initialStep: 1,
                      min: 0,
                      allowEmpty: true,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
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
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
