import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';
import 'package:my_fitness_tracker/presentation/onboarding/onboarding_state.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';
import 'package:uuid/uuid.dart';

class ProfileSetupData {
  const ProfileSetupData({
    required this.name,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
  });

  final String name;
  final int age;
  final BiologicalSex sex;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String activityLevel;
}

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key, this.onCompleted});

  final void Function(ProfileSetupData data)? onCompleted;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKeys = List<GlobalKey<FormState>>.generate(
    4,
    (_) => GlobalKey<FormState>(),
  );
  final PageController _controller = PageController();
  int _currentStep = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  BiologicalSex _sex = BiologicalSex.male;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _goal = 'mantener';
  String _activity = 'moderado';
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _controller.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _nextStep() async {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep == 3) {
        await _complete();
      } else {
        _goToStep(_currentStep + 1);
      }
    }
  }

  Future<void> _complete() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final data = ProfileSetupData(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      sex: _sex,
      heightCm: _parseNumber(_heightController.text),
      weightKg: _parseNumber(_weightController.text),
      goal: _goal,
      activityLevel: _activity,
    );

    try {
      final repository = await ref.read(metricsRepositoryProvider.future);

      final profile = MetabolicProfile(
        id: const Uuid().v4(),
        updatedAt: DateTime.now(),
        heightCm: data.heightCm,
        weightKg: data.weightKg,
        age: data.age,
        sex: data.sex,
        activityMultiplier: _mapActivityToMultiplier(data.activityLevel),
      );

      await repository.saveMetabolicProfile(profile);

      final BodyMetric initialMetric = BodyMetric(
        id: const Uuid().v4(),
        recordedAt: DateTime.now(),
        weightKg: data.weightKg,
        bodyFatPercentage: null,
        muscleMassKg: null,
        notes: 'Registro inicial del perfil',
        measurements: const <String, double>{},
      );

      await repository.upsertMetric(initialMetric);

      await ref
          .read(onboardingPersistenceProvider)
          .markProfileSetupComplete();
      ref.invalidate(metabolicProfileProvider);
      ref.invalidate(bodyMetricsProvider);
      ref.invalidate(filteredMetricsProvider);
      ref.invalidate(latestBodyMetricProvider);
      ref.invalidate(onboardingStatusProvider);

      widget.onCompleted?.call(data);
      if (mounted) {
        Navigator.of(context).maybePop(data);
      }
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        'No pudimos guardar tu perfil: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu perfil'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: AppColors.veryLightGray,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accentBlue,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _basicInfoForm(theme),
                  _measurementsForm(theme),
                  _goalForm(theme),
                  _activityForm(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentStep == 0
                          ? null
                          : () => _goToStep(_currentStep - 1),
                      child: const Text('Atrás'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _nextStep(),
                      child: Text(
                        _currentStep == 3
                            ? (_isSaving ? 'Guardando...' : 'Finalizar')
                            : 'Siguiente',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _parseNumber(String value) =>
      double.parse(value.replaceAll(',', '.'));

  double _mapActivityToMultiplier(String activity) {
    switch (activity) {
      case 'sedentario':
        return 1.2;
      case 'ligero':
        return 1.375;
      case 'moderado':
        return 1.55;
      case 'intenso':
        return 1.725;
      default:
        return 1.2;
    }
  }

  Widget _basicInfoForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos básicos',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Ingresa tu nombre'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final age = int.tryParse(value ?? '');
                if (age == null || age < 13 || age > 100) {
                  return 'Ingresa una edad válida (13-100)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BiologicalSex>(
              initialValue: _sex,
              decoration: const InputDecoration(labelText: 'Sexo'),
              items: const [
                DropdownMenuItem(
                  value: BiologicalSex.male,
                  child: Text('Masculino'),
                ),
                DropdownMenuItem(
                  value: BiologicalSex.female,
                  child: Text('Femenino'),
                ),
                DropdownMenuItem(
                  value: BiologicalSex.other,
                  child: Text('Otro'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _sex = value ?? BiologicalSex.male),
            ),
          ],
        ),
      ),
    );
  }

  Widget _measurementsForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medidas iniciales',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Altura (cm)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final height = double.tryParse(value ?? '');
                if (height == null || height < 100 || height > 250) {
                  return 'Ingresa una altura válida (100-250 cm)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final weight = double.tryParse(value ?? '');
                if (weight == null || weight < 20 || weight > 300) {
                  return 'Ingresa un peso válido (20-300 kg)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objetivo principal',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'perder',
                  label: Text('Perder peso'),
                ),
                ButtonSegment<String>(
                  value: 'mantener',
                  label: Text('Mantenerme'),
                ),
                ButtonSegment<String>(
                  value: 'ganar',
                  label: Text('Ganar masa muscular'),
                ),
              ],
              selected: <String>{_goal},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  setState(() => _goal = selection.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nivel de actividad',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _activity,
              decoration: const InputDecoration(
                labelText: 'Selecciona tu nivel',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'sedentario',
                  child: Text('Sedentario'),
                ),
                DropdownMenuItem(
                  value: 'ligero',
                  child: Text('Ligero (1-2 días)'),
                ),
                DropdownMenuItem(
                  value: 'moderado',
                  child: Text('Moderado (3-4 días)'),
                ),
                DropdownMenuItem(
                  value: 'intenso',
                  child: Text('Intenso (5+ días)'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _activity = value ?? 'moderado'),
            ),
            const SizedBox(height: 16),
            Text(
              'Esto nos ayuda a recomendar mejor tu ingesta calórica y ritmo de progreso.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
