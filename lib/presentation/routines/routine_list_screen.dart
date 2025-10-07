import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/routines/routine_service.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';

class RoutineListScreen extends ConsumerWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routineListControllerProvider);
    final serviceAsync = ref.watch(routineServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(routineListControllerProvider.notifier).refresh(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComingSoon(context),
        icon: const Icon(Icons.add),
        label: const Text('Crear rutina'),
      ),
      body: routinesAsync.when(
        data: (List<Routine> routines) {
          if (routines.isEmpty) {
            return const _EmptyRoutineView();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: routines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final routine = routines[index];
              return _RoutineTile(
                routine: routine,
                onArchive: () => _handleArchive(context, ref, serviceAsync, routine),
                onDuplicate: () => _handleDuplicate(context, ref, serviceAsync, routine),
              );
            },
          );
        },
        error: (Object error, StackTrace stackTrace) => _ErrorState(error: error, onRetry: () => ref.read(routineListControllerProvider.notifier).refresh()),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El constructor de rutinas estará disponible en la siguiente iteración.')),
    );
  }

  Future<void> _handleArchive(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<RoutineService> serviceAsync,
    Routine routine,
  ) async {
    final service = serviceAsync.value;
    if (service == null) {
      _showServiceError(context);
      return;
    }
    await service.archive(routine.id);
    if (!context.mounted) return;
    await ref.read(routineListControllerProvider.notifier).refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rutina "${routine.name}" archivada.')),
    );
  }

  Future<void> _handleDuplicate(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<RoutineService> serviceAsync,
    Routine routine,
  ) async {
    final service = serviceAsync.value;
    if (service == null) {
      _showServiceError(context);
      return;
    }
    final duplicated = await service.duplicate(routine.id);
    if (!context.mounted) return;
    await ref.read(routineListControllerProvider.notifier).refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rutina duplicada como "${duplicated.name}".')),
    );
  }

  void _showServiceError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio no disponible. Intenta nuevamente.')),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({
    required this.routine,
    required this.onArchive,
    required this.onDuplicate,
  });

  final Routine routine;
  final VoidCallback onArchive;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusLabel = routine.focus.name.toUpperCase();
    final chips = routine.daysOfWeek.map((RoutineDay day) => day.shortLabel).join(' · ');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        focusLabel,
                        style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: onDuplicate,
                  tooltip: 'Duplicar',
                ),
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: onArchive,
                  tooltip: 'Archivar',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                Chip(label: Text(chips)),
                Chip(label: Text('${routine.exercises.length} ejercicios')),
              ],
            ),
            if (routine.description.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                routine.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutineView extends StatelessWidget {
  const _EmptyRoutineView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.playlist_add_check_circle_rounded, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 18),
            Text(
              'Aún no tienes rutinas creadas',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Genera tu primera rutina para comenzar a registrar tus sesiones y analizar tu progreso.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar tus rutinas',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}
