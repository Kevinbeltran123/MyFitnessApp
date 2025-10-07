import 'dart:async';

import 'package:flutter/material.dart';

import 'package:my_fitness_tracker/models/workout_plan.dart';
import 'package:my_fitness_tracker/services/api_client.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';
import 'package:my_fitness_tracker/widgets/empty_exercises_state.dart';
import 'package:my_fitness_tracker/widgets/exercise_grid_item.dart';
import 'package:my_fitness_tracker/widgets/exercise_search_bar.dart';
import 'package:my_fitness_tracker/widgets/filter_chips_row.dart';
import 'package:my_fitness_tracker/widgets/workout_detail_sheet.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late final ApiClient _apiClient;
  late final WorkoutService _workoutService;
  final SearchController _searchController = SearchController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedMuscles = <String>{};
  final Set<String> _selectedEquipments = <String>{};
  final Map<String, List<WorkoutPlan>> _cache = <String, List<WorkoutPlan>>{};
  final Map<String, WorkoutPaginationMetadata?> _metadataCache =
      <String, WorkoutPaginationMetadata?>{};

  WorkoutAvailableFilters? _availableFilters;
  List<WorkoutPlan> _results = <WorkoutPlan>[];
  WorkoutPaginationMetadata? _pagination;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  Timer? _debounce;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _workoutService = WorkoutService(_apiClient);
    _scrollController.addListener(_handleScroll);
    _initialize();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _apiClient.close();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _fetchFilters();
    await _loadExercises(reset: true);
  }

  Future<void> _fetchFilters() async {
    try {
      final filters = await _workoutService.getAvailableFilters();
      if (!mounted) {
        return;
      }
      setState(() {
        _availableFilters = filters;
      });
    } catch (_) {
      // Continuamos con filtros por defecto aunque falle la carga remota.
    }
  }

  Future<void> _loadExercises({bool reset = false}) async {
    if (!mounted) {
      return;
    }
    if (_isLoadingMore || (_isLoading && !reset)) {
      return;
    }

    final String query = _searchController.text.trim();
    final String? muscle = _selectedMuscles.isEmpty
        ? null
        : _selectedMuscles.first;
    final String? equipment = _selectedEquipments.isEmpty
        ? null
        : _selectedEquipments.first;
    final String cacheKey = _buildCacheKey(query, muscle, equipment);

    final List<WorkoutPlan>? cachedResults = reset ? _cache[cacheKey] : null;
    final WorkoutPaginationMetadata? cachedMetadata = reset
        ? _metadataCache[cacheKey]
        : null;

    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        if (cachedResults != null) {
          _results = List<WorkoutPlan>.from(cachedResults);
          _pagination = cachedMetadata;
          _hasMore =
              (_pagination?.totalExercises ?? _results.length) >
              _results.length;
        } else {
          _results = <WorkoutPlan>[];
          _hasMore = true;
        }
      });

      if (cachedResults != null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await _workoutService.searchExercises(
        query,
        muscle: muscle,
        equipment: equipment,
        limit: _pageSize,
        offset: reset ? 0 : _results.length,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (reset) {
          _results = response.plans;
        } else {
          final Set<String> seenIds = _results
              .map((plan) => plan.exerciseId)
              .toSet();
          final List<WorkoutPlan> updated = List<WorkoutPlan>.from(_results);
          for (final WorkoutPlan plan in response.plans) {
            if (seenIds.add(plan.exerciseId)) {
              updated.add(plan);
            }
          }
          _results = updated;
        }

        _pagination = response.metadata;
        _hasMore = response.plans.length >= _pageSize;
        _errorMessage = null;
      });

      if (reset) {
        _cache[cacheKey] = List<WorkoutPlan>.from(_results);
        _metadataCache[cacheKey] = _pagination;
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        if (reset) {
          _results = <WorkoutPlan>[];
          _hasMore = false;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          if (reset) {
            _isLoading = false;
          }
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onQueryChanged(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      _loadExercises(reset: true);
    });
  }

  void _handleScroll() {
    if (!_hasMore || _isLoadingMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadExercises();
    }
  }

  Future<void> _onRefresh() async {
    await _loadExercises(reset: true);
  }

  void _toggleMuscle(String value) {
    setState(() {
      if (_selectedMuscles.contains(value)) {
        _selectedMuscles.clear();
      } else {
        _selectedMuscles
          ..clear()
          ..add(value);
      }
    });
    _loadExercises(reset: true);
  }

  void _toggleEquipment(String value) {
    setState(() {
      if (_selectedEquipments.contains(value)) {
        _selectedEquipments.clear();
      } else {
        _selectedEquipments
          ..clear()
          ..add(value);
      }
    });
    _loadExercises(reset: true);
  }

  void _clearAll() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedMuscles.clear();
      _selectedEquipments.clear();
    });
    _loadExercises(reset: true);
  }

  void _openDetail(WorkoutPlan plan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => WorkoutDetailSheet(plan: plan),
    );
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      _selectedMuscles.isNotEmpty ||
      _selectedEquipments.isNotEmpty;

  int get _resultsCount => _pagination?.totalExercises ?? _results.length;

  @override
  Widget build(BuildContext context) {
    final filters = _availableFilters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ExerciseSearchBar(
              controller: _searchController,
              onQueryChanged: _onQueryChanged,
              onClear: _clearAll,
              isSearching: _isLoading && _results.isEmpty,
            ),
          ),
        ),
      ),
      floatingActionButton: _hasActiveFilters
          ? FloatingActionButton.extended(
              onPressed: _clearAll,
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Limpiar filtros'),
            )
          : null,
      body: SafeArea(child: _buildBody(filters)),
    );
  }

  Widget _buildBody(WorkoutAvailableFilters? filters) {
    if (_isLoading && _results.isEmpty) {
      return _buildLoadingState(filters);
    }

    if (_errorMessage != null && _results.isEmpty) {
      return _buildErrorState();
    }

    if (_results.isEmpty) {
      return EmptyExercisesState(
        message: 'No encontramos ejercicios con esos criterios.',
        onReset: _hasActiveFilters ? _clearAll : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 12),
                FilterChipsRow(
                  muscles: filters?.muscles ?? const <String>[],
                  equipments: filters?.equipments ?? const <String>[],
                  selectedMuscles: _selectedMuscles,
                  selectedEquipments: _selectedEquipments,
                  onMuscleToggle: _toggleMuscle,
                  onEquipmentToggle: _toggleEquipment,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '$_resultsCount ejercicios encontrados',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
          _buildGridSliver(),
          SliverToBoxAdapter(child: SizedBox(height: _isLoadingMore ? 72 : 16)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(WorkoutAvailableFilters? filters) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 12),
              FilterChipsRow(
                muscles: filters?.muscles ?? const <String>[],
                equipments: filters?.equipments ?? const <String>[],
                selectedMuscles: _selectedMuscles,
                selectedEquipments: _selectedEquipments,
                onMuscleToggle: _toggleMuscle,
                onEquipmentToggle: _toggleEquipment,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Cargando ejercicios...'),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              return const ExerciseGridPlaceholder();
            }, childCount: 6),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Ocurrió un problema al cargar los ejercicios.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadExercises(reset: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildGridSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          if (index >= _results.length) {
            return const ExerciseGridPlaceholder();
          }
          final WorkoutPlan plan = _results[index];
          return ExerciseGridItem(plan: plan, onTap: () => _openDetail(plan));
        }, childCount: _results.length + (_isLoadingMore ? 2 : 0)),
      ),
    );
  }

  String _buildCacheKey(String query, String? muscle, String? equipment) {
    return '${query.toLowerCase()}|${muscle ?? ''}|${equipment ?? ''}';
  }
}
