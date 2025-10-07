import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_builder_screen.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_session_screen.dart';

class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineAsync = ref.watch(routineByIdProvider(routineId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de rutina'),
        actions: routineAsync.maybeWhen(
          data: (Routine? routine) {
            if (routine == null) {
              return <Widget>[];
            }
            return <Widget>[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar',
                onPressed: () async {
                  final updated = await Navigator.of(context).push<Routine>(
                    MaterialPageRoute<Routine>(
                      fullscreenDialog: true,
                      builder: (BuildContext context) =>
                          RoutineBuilderScreen(initialRoutine: routine),
                    ),
                  );
                  if (updated != null) {
                    ref.invalidate(routineByIdProvider(routineId));
                    ref.invalidate(routineListControllerProvider);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Rutina "${updated.name}" actualizada.'),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Duplicar',
                onPressed: () async {
                  try {
                    final service = await ref.read(
                      routineServiceProvider.future,
                    );
                    final duplicated = await service.duplicate(routine.id);
                    ref.invalidate(routineByIdProvider(routineId));
                    ref.invalidate(routineListControllerProvider);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Rutina duplicada como "${duplicated.name}".',
                        ),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se pudo duplicar la rutina.'),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  routine.isArchived
                      ? Icons.unarchive_outlined
                      : Icons.archive_outlined,
                ),
                tooltip: routine.isArchived ? 'Restaurar' : 'Archivar',
                onPressed: () async {
                  try {
                    final service = await ref.read(
                      routineServiceProvider.future,
                    );
                    if (routine.isArchived) {
                      await service.restore(routine.id);
                    } else {
                      await service.archive(routine.id);
                    }
                    ref.invalidate(routineByIdProvider(routineId));
                    ref.invalidate(routineListControllerProvider);
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se pudo actualizar el estado de la rutina.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ];
          },
          orElse: () => <Widget>[],
        ),
      ),
      body: routineAsync.when(
        data: (Routine? routine) {
          if (routine == null) {
            return const _EmptyRoutineDetail();
          }
          final theme = Theme.of(context);
          final activeDays = routine.daysOfWeek
              .map((RoutineDay day) => day.shortLabel)
              .join(' · ');
          final totalSets = routine.exercises
              .expand((RoutineExercise e) => e.sets)
              .length;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            routine.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            routine.isArchived
                                ? 'Archivada'
                                : routine.focus.name.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              letterSpacing: 1.1,
                              color: routine.isArchived
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.calendar_month,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Días: $activeDays', style: theme.textTheme.bodyLarge),
                Text(
                  'Series totales: $totalSets',
                  style: theme.textTheme.bodyMedium,
                ),
                if (routine.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(routine.description, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 24),
                Text('Ejercicios', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final RoutineExercise exercise in routine.exercises)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            exercise.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: <Widget>[
                              Chip(
                                label: Text(
                                  exercise.targetMuscles.take(2).join(' · '),
                                ),
                              ),
                              if (exercise.equipment != null)
                                Chip(label: Text(exercise.equipment!)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (final RoutineSet set in exercise.sets)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Serie ${set.setNumber}: ${set.repetitions} reps · '
                                '${(set.targetWeight ?? 0) > 0 ? '${set.targetWeight!.toStringAsFixed(1)} kg' : 'Peso libre'} · '
                                '${set.restInterval != null ? '${set.restInterval!.inSeconds}s descanso' : 'Sin descanso sugerido'}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            RoutineSessionScreen(routineId: routine.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Iniciar entrenamiento'),
                ),
              ],
            ),
          );
        },
        error: (_, __) =>
            const Center(child: Text('No se pudo cargar la rutina.')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EmptyRoutineDetail extends StatelessWidget {
  const _EmptyRoutineDetail();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('No encontramos la rutina solicitada.'),
      ),
    );
  }
}
