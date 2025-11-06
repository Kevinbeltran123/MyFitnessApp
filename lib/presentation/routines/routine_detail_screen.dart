import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_builder_screen.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_session_screen.dart';
import 'package:my_fitness_tracker/shared/utils/app_snackbar.dart';
import 'package:my_fitness_tracker/shared/widgets/state_widgets.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  const RoutineDetailScreen({super.key, required this.routineId});

  final String routineId;

  @override
  ConsumerState<RoutineDetailScreen> createState() =>
      _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  bool _isProcessing = false;

  Future<T?> _withProcessing<T>(Future<T> Function() task) async {
    if (mounted && !_isProcessing) {
      setState(() => _isProcessing = true);
    }
    try {
      return await task();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleEdit(BuildContext context, Routine routine) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Routine? updated = await Navigator.of(context).push<Routine>(
      MaterialPageRoute<Routine>(
        fullscreenDialog: true,
        builder: (BuildContext context) =>
            RoutineBuilderScreen(initialRoutine: routine),
      ),
    );
    if (updated != null && mounted) {
      ref.invalidate(routineByIdProvider(widget.routineId));
      ref.invalidate(routineListControllerProvider);
      messenger.showSnackBar(
        AppSnackBar.successSnack('Rutina "${updated.name}" actualizada.'),
      );
    }
  }

  Future<void> _handleDuplicate(BuildContext context, Routine routine) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final duplicated = await _withProcessing(() async {
        final service = await ref.read(routineServiceProvider.future);
        return service.duplicate(routine.id);
      });
      if (!mounted || duplicated == null) {
        return;
      }
      ref.invalidate(routineListControllerProvider);
      messenger.showSnackBar(
        AppSnackBar.successSnack('Rutina duplicada como "${duplicated.name}".'),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        AppSnackBar.errorSnack('No se pudo duplicar la rutina.'),
      );
    }
  }

  Future<void> _handleArchiveToggle(
    BuildContext context,
    Routine routine,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool targetArchived = !routine.isArchived;
    try {
      await _withProcessing(() async {
        final service = await ref.read(routineServiceProvider.future);
        if (targetArchived) {
          await service.archive(routine.id);
        } else {
          await service.restore(routine.id);
        }
      });
      if (!mounted) return;
      ref.invalidate(routineByIdProvider(widget.routineId));
      ref.invalidate(routineListControllerProvider);
      final String message = targetArchived
          ? 'Rutina "${routine.name}" archivada.'
          : 'Rutina "${routine.name}" restaurada.';
      messenger.showSnackBar(AppSnackBar.infoSnack(message));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        AppSnackBar.errorSnack('No se pudo actualizar el estado de la rutina.'),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context, Routine routine) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final ThemeData theme = Theme.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar rutina'),
          content: Text(
            '¿Deseas eliminar la rutina "${routine.name}" de forma permanente? '
            'Esta acción no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    try {
      await _withProcessing(() async {
        final service = await ref.read(routineServiceProvider.future);
        await service.delete(routine.id, hardDelete: true);
      });
      if (!mounted) {
        return;
      }
      ref.invalidate(routineListControllerProvider);
      navigator.pop(RoutineDetailResult.deleted(routine.name));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        AppSnackBar.errorSnack(
          'No pudimos eliminar la rutina. Intenta nuevamente.',
        ),
      );
    }
  }

  void _startWorkout(BuildContext context, Routine routine) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RoutineSessionScreen(routineId: routine.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routineAsync = ref.watch(routineByIdProvider(widget.routineId));
    final lastUsedAsync = ref.watch(routineLastUsedProvider);

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
                onPressed: _isProcessing
                    ? null
                    : () => _handleEdit(context, routine),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Duplicar',
                onPressed: _isProcessing
                    ? null
                    : () => _handleDuplicate(context, routine),
              ),
              IconButton(
                icon: Icon(
                  routine.isArchived
                      ? Icons.unarchive_outlined
                      : Icons.archive_outlined,
                ),
                tooltip: routine.isArchived ? 'Restaurar' : 'Archivar',
                onPressed: _isProcessing
                    ? null
                    : () => _handleArchiveToggle(context, routine),
              ),
              PopupMenuButton<_DetailMenuAction>(
                enabled: !_isProcessing,
                onSelected: (value) {
                  if (value == _DetailMenuAction.delete) {
                    _handleDelete(context, routine);
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<_DetailMenuAction>>[
                      const PopupMenuItem<_DetailMenuAction>(
                        value: _DetailMenuAction.delete,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Eliminar rutina'),
                        ),
                      ),
                    ],
              ),
            ];
          },
          orElse: () => <Widget>[],
        ),
      ),
      body: Column(
        children: <Widget>[
          if (_isProcessing) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: routineAsync.when(
              data: (Routine? routine) {
                if (routine == null) {
                  return const _EmptyRoutineDetail();
                }
                final Map<String, DateTime> lastUsedMap = lastUsedAsync
                    .maybeWhen(
                      data: (Map<String, DateTime> value) => value,
                      orElse: () => const <String, DateTime>{},
                    );
                return _RoutineDetailContent(
                  routine: routine,
                  lastUsedAt: lastUsedMap[routine.id],
                  onStartPressed: () => _startWorkout(context, routine),
                );
              },
              error: (Object error, StackTrace stackTrace) => _LoadErrorView(
                error: error,
                onRetry: () =>
                    ref.refresh(routineByIdProvider(widget.routineId)),
              ),
              loading: () => const LoadingStateWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineDetailContent extends StatelessWidget {
  const _RoutineDetailContent({
    required this.routine,
    required this.lastUsedAt,
    required this.onStartPressed,
  });

  final Routine routine;
  final DateTime? lastUsedAt;
  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String focusLabel = _focusLabel(routine.focus);
    final List<String> dayLabels = routine.daysOfWeek
        .map((RoutineDay day) => day.shortLabel)
        .toList(growable: false);
    final int totalSets = routine.exercises
        .expand((RoutineExercise e) => e.sets)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: <Widget>[
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: <Widget>[
                              Chip(
                                avatar: const Icon(Icons.flag, size: 16),
                                label: Text(focusLabel),
                              ),
                              Chip(
                                avatar: const Icon(
                                  Icons.fitness_center,
                                  size: 16,
                                ),
                                label: Text(
                                  '${routine.exercises.length} ejercicios',
                                ),
                              ),
                              Chip(
                                avatar: const Icon(Icons.list_alt, size: 16),
                                label: Text('$totalSets series'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      routine.isArchived
                          ? Icons.archive_outlined
                          : Icons.calendar_month,
                      color: routine.isArchived
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                  ],
                ),
                if (routine.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(routine.description, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (dayLabels.isNotEmpty)
          _InfoSection(
            title: 'Días programados',
            child: Wrap(
              spacing: 12,
              children: dayLabels
                  .map((String label) => Chip(label: Text(label)))
                  .toList(growable: false),
            ),
          ),
        _InfoSection(
          title: 'Resumen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _InfoRow(
                icon: Icons.access_time,
                label: 'Último uso',
                value: lastUsedAt != null
                    ? '${localizations.formatMediumDate(lastUsedAt!)} · '
                          '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(lastUsedAt!))}'
                    : 'Aún no has registrado sesiones',
              ),
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Creada',
                value: localizations.formatMediumDate(routine.createdAt),
              ),
              _InfoRow(
                icon: Icons.update,
                label: 'Actualizada',
                value: localizations.formatMediumDate(routine.updatedAt),
              ),
            ],
          ),
        ),
        _ExercisesSection(exercises: routine.exercises),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const ValueKey<String>('routine-detail-start'),
          onPressed: onStartPressed,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Iniciar entrenamiento'),
        ),
      ],
    );
  }
}

class _ExercisesSection extends StatelessWidget {
  const _ExercisesSection({required this.exercises});

  final List<RoutineExercise> exercises;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (exercises.isEmpty) {
      return _InfoSection(
        title: 'Ejercicios',
        child: Text(
          'Esta rutina aún no tiene ejercicios configurados. Agrega algunos desde el modo de edición.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return _InfoSection(
      title: 'Ejercicios',
      child: Column(
        children: <Widget>[
          for (final RoutineExercise exercise in exercises)
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
                      runSpacing: 4,
                      children: <Widget>[
                        if (exercise.targetMuscles.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.bolt, size: 16),
                            label: Text(
                              exercise.targetMuscles.take(2).join(' · '),
                            ),
                          ),
                        if (exercise.equipment != null)
                          Chip(
                            avatar: const Icon(Icons.handyman, size: 16),
                            label: Text(exercise.equipment!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: <Widget>[
                        for (final RoutineSet set in exercise.sets)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              foregroundColor:
                                  theme.colorScheme.onPrimaryContainer,
                              child: Text('${set.setNumber}'),
                            ),
                            title: Text(
                              '${set.repetitions} repeticiones'
                              '${set.targetWeight != null && set.targetWeight! > 0 ? ' · ${set.targetWeight!.toStringAsFixed(1)} kg' : ''}',
                            ),
                            subtitle: Text(
                              set.restInterval != null
                                  ? 'Descanso sugerido: ${set.restInterval!.inSeconds}s'
                                  : 'Sin descanso sugerido',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: theme.textTheme.labelLarge),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'No se pudo cargar la rutina',
      message: error.toString(),
      onRetry: onRetry,
      retryLabel: 'Intentar nuevamente',
    );
  }
}

class _EmptyRoutineDetail extends StatelessWidget {
  const _EmptyRoutineDetail();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.help_outline,
      title: 'No encontramos la rutina solicitada.',
      message:
          'Es posible que haya sido eliminada o que aún no se haya sincronizado correctamente.',
    );
  }
}

String _focusLabel(RoutineFocus focus) {
  switch (focus) {
    case RoutineFocus.fullBody:
      return 'Cuerpo completo';
    case RoutineFocus.upperBody:
      return 'Tren superior';
    case RoutineFocus.lowerBody:
      return 'Tren inferior';
    case RoutineFocus.push:
      return 'Push';
    case RoutineFocus.pull:
      return 'Pull';
    case RoutineFocus.core:
      return 'Core';
    case RoutineFocus.mobility:
      return 'Movilidad';
    case RoutineFocus.custom:
      return 'Personalizada';
  }
}

enum _DetailMenuAction { delete }

class RoutineDetailResult {
  const RoutineDetailResult._(this.action, this.payload);

  const RoutineDetailResult.deleted(String routineName)
    : this._(RoutineDetailAction.deleted, routineName);

  final RoutineDetailAction action;
  final Object? payload;

  String? get routineName => payload as String?;
}

enum RoutineDetailAction { deleted }
