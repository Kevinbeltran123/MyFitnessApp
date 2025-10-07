import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_builder_screen.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_detail_screen.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_controller.dart';

class RoutineListScreen extends ConsumerStatefulWidget {
  const RoutineListScreen({super.key});

  @override
  ConsumerState<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends ConsumerState<RoutineListScreen> {
  final TextEditingController _searchController = TextEditingController();
  RoutineFocus? _selectedFocus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routineListControllerProvider);
    final lastUsedAsync = ref.watch(routineLastUsedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(routineListControllerProvider.notifier).refresh(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRoutineBuilder,
        icon: const Icon(Icons.add),
        label: const Text('Crear rutina'),
      ),
      body: routinesAsync.when(
        data: (List<Routine> routines) {
          final Map<String, DateTime> lastUsedMap =
              lastUsedAsync.asData?.value ?? const <String, DateTime>{};

          final List<Routine> active = routines
              .where((Routine routine) => !routine.isArchived)
              .toList();
          final List<Routine> archived = routines
              .where((Routine routine) => routine.isArchived)
              .toList();

          final List<Routine> filteredActive = active
              .where(_matchesFilters)
              .toList();
          final List<Routine> filteredArchived = archived
              .where(_matchesFilters)
              .toList();

          final bool hasAnyRoutines = active.isNotEmpty || archived.isNotEmpty;
          final bool hasFilteredResults =
              filteredActive.isNotEmpty || filteredArchived.isNotEmpty;

          final List<Widget> children = <Widget>[
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildFocusFilterRow(),
            if (lastUsedAsync.hasError) ...<Widget>[
              const SizedBox(height: 12),
              _ErrorBanner(
                message:
                    'No pudimos cargar el historial de tus rutinas. Usaremos la última actualización disponible.',
                onRetry: () => ref.refresh(routineLastUsedProvider),
              ),
            ],
            const SizedBox(height: 16),
          ];

          if (!hasAnyRoutines) {
            children.add(_EmptyRoutineView(onCreate: _openRoutineBuilder));
          } else if (!hasFilteredResults) {
            children.add(
              _NoResultsView(
                onClearFilters: _clearFilters,
                isFiltering: _isFiltering,
              ),
            );
          } else {
            if (filteredActive.isNotEmpty && filteredArchived.isNotEmpty) {
              children.add(const _SectionLabel(label: 'Activas'));
              children.add(const SizedBox(height: 8));
            }

            for (final Routine routine in filteredActive) {
              children.add(
                _RoutineTile(
                  routine: routine,
                  lastUsedAt: lastUsedMap[routine.id],
                  onTap: () => _openDetail(routine.id),
                  onArchive: () => _handleArchive(context, ref, routine),
                  onDuplicate: () => _handleDuplicate(context, ref, routine),
                ),
              );
            }

            if (filteredArchived.isNotEmpty) {
              if (filteredActive.isNotEmpty) {
                children.add(const SizedBox(height: 16));
              }
              children.add(const _SectionLabel(label: 'Archivadas'));
              children.add(const SizedBox(height: 8));
              for (final Routine routine in filteredArchived) {
                children.add(
                  _RoutineTile(
                    routine: routine,
                    lastUsedAt: lastUsedMap[routine.id],
                    onTap: () => _openDetail(routine.id),
                    onRestore: () => _handleRestore(context, ref, routine),
                  ),
                );
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: children,
          );
        },
        error: (Object error, StackTrace stackTrace) => _ErrorState(
          error: error,
          onRetry: () =>
              ref.read(routineListControllerProvider.notifier).refresh(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  bool get _isFiltering =>
      _searchController.text.trim().isNotEmpty || _selectedFocus != null;

  bool _matchesFilters(Routine routine) {
    final String query = _searchController.text.trim().toLowerCase();
    final bool matchesQuery =
        query.isEmpty ||
        routine.name.toLowerCase().contains(query) ||
        routine.description.toLowerCase().contains(query);
    final bool matchesFocus =
        _selectedFocus == null || routine.focus == _selectedFocus;
    return matchesQuery && matchesFocus;
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Buscar rutina',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.close),
                tooltip: 'Limpiar búsqueda',
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textInputAction: TextInputAction.search,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildFocusFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: _selectedFocus == null,
              onSelected: (_) => setState(() => _selectedFocus = null),
            ),
          ),
          for (final RoutineFocus focus in RoutineFocus.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_focusLabel(focus)),
                selected: _selectedFocus == focus,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedFocus = selected ? focus : null;
                  });
                },
              ),
            ),
        ],
      ),
    );
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

  void _clearFilters() {
    if (!_isFiltering) {
      return;
    }
    setState(() {
      _searchController.clear();
      _selectedFocus = null;
    });
  }

  void _openRoutineBuilder() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RoutineBuilderScreen(),
      ),
    );
  }

  void _openDetail(String routineId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            RoutineDetailScreen(routineId: routineId),
      ),
    );
  }

  Future<void> _handleArchive(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) async {
    try {
      final service = await ref.read(routineServiceProvider.future);
      await service.archive(routine.id);
      if (!context.mounted) return;
      await ref.read(routineListControllerProvider.notifier).refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rutina "${routine.name}" archivada.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showServiceError(context);
    }
  }

  Future<void> _handleRestore(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) async {
    try {
      final service = await ref.read(routineServiceProvider.future);
      await service.restore(routine.id);
      if (!context.mounted) return;
      await ref.read(routineListControllerProvider.notifier).refresh();
    } catch (_) {
      if (!context.mounted) return;
      _showServiceError(context);
    }
  }

  Future<void> _handleDuplicate(
    BuildContext context,
    WidgetRef ref,
    Routine routine,
  ) async {
    try {
      final service = await ref.read(routineServiceProvider.future);
      final Routine duplicated = await service.duplicate(routine.id);
      if (!context.mounted) return;
      await ref.read(routineListControllerProvider.notifier).refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rutina duplicada como "${duplicated.name}".')),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showServiceError(context);
    }
  }

  void _showServiceError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Servicio no disponible. Intenta nuevamente.'),
      ),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({
    required this.routine,
    this.lastUsedAt,
    this.onTap,
    this.onArchive,
    this.onRestore,
    this.onDuplicate,
  });

  final Routine routine;
  final DateTime? lastUsedAt;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onDuplicate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String focusLabel = routine.focus.name.toUpperCase();
    final bool archived = routine.isArchived;

    final List<String> dayLabels = routine.daysOfWeek
        .map((RoutineDay day) => day.shortLabel)
        .toList();

    final DateTime referenceDate = lastUsedAt ?? routine.updatedAt;
    final String subtitle = lastUsedAt != null
        ? 'Último uso: ${localizations.formatMediumDate(lastUsedAt!)}'
        : 'Actualizada: ${localizations.formatMediumDate(referenceDate)}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: archived ? theme.colorScheme.outline : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          archived ? 'ARCHIVADA' : focusLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.2,
                            color: archived
                                ? theme.colorScheme.outline
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDuplicate != null)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: onDuplicate,
                      tooltip: 'Duplicar',
                    ),
                  if (!archived && onArchive != null)
                    IconButton(
                      icon: const Icon(Icons.archive_outlined),
                      onPressed: onArchive,
                      tooltip: 'Archivar',
                    )
                  else if (archived && onRestore != null)
                    IconButton(
                      icon: const Icon(Icons.unarchive_outlined),
                      onPressed: onRestore,
                      tooltip: 'Restaurar',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  if (dayLabels.isNotEmpty)
                    Chip(label: Text(dayLabels.join(' · '))),
                  Chip(label: Text('${routine.exercises.length} ejercicios')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.history,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
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
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyRoutineView extends StatelessWidget {
  const _EmptyRoutineView({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.playlist_add_check_circle_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
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
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear rutina'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({
    required this.onClearFilters,
    required this.isFiltering,
  });

  final VoidCallback onClearFilters;
  final bool isFiltering;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No encontramos rutinas con esos criterios.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltering
                  ? 'Prueba a ajustar la búsqueda o filtros para ver más resultados.'
                  : 'Crea tu primera rutina para comenzar.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (isFiltering) ...<Widget>[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(
          Icons.info_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
        title: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
        trailing: onRetry != null
            ? TextButton(onPressed: onRetry, child: const Text('Reintentar'))
            : null,
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
