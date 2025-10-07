import 'package:my_fitness_tracker/models/workout_plan.dart';
import 'package:my_fitness_tracker/services/api_client.dart';
import 'package:my_fitness_tracker/utils/app_exceptions.dart';
import 'package:my_fitness_tracker/utils/constants.dart';

class WorkoutService {
  WorkoutService(this._client);

  final ApiClient _client;
  WorkoutAvailableFilters? _cachedFilters;

  Uri _buildUri(String path, [Map<String, String?>? queryParameters]) {
    final base = Uri.parse(AppConstants.workoutsBaseUrl);
    final filteredParams = <String, String>{};
    if (queryParameters != null) {
      for (final MapEntry<String, String?> entry in queryParameters.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value != null && value.isNotEmpty) {
          filteredParams[key] = value;
        }
      }
    }

    return Uri(
      scheme: base.scheme,
      host: base.host,
      path: '${base.path}/api/v1$path'.replaceAll('//', '/'),
      queryParameters: filteredParams.isEmpty ? null : filteredParams,
    );
  }

  Future<WorkoutPlansResponse> fetchExercises({
    int limit = 10,
    int offset = 0,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    final uri = _buildUri('/exercises', <String, String?>{
      'limit': limit.clamp(1, 100).toString(),
      if (offset > 0) 'offset': offset.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    });

    final json = await _client.get(uri);
    _ensureSuccess(json);
    return WorkoutPlansResponse.fromJson(json);
  }

  Future<WorkoutPlansResponse> searchExercises(
    String query, {
    String? muscle,
    String? equipment,
    int limit = 10,
    int offset = 0,
    double threshold = 0.3,
  }) async {
    final trimmedQuery = query.trim();
    final normalizedMuscle = _normalizeFilterValue(muscle);
    final normalizedEquipment = _normalizeFilterValue(equipment);
    final bool hasQuery = trimmedQuery.isNotEmpty;
    final bool hasFilters =
        (normalizedMuscle != null && normalizedMuscle.isNotEmpty) ||
        (normalizedEquipment != null && normalizedEquipment.isNotEmpty);

    if (!hasQuery && !hasFilters) {
      return fetchExercises(limit: limit, offset: offset);
    }

    if (hasFilters) {
      final response = await filterExercises(
        targetMuscle: normalizedMuscle,
        equipment: normalizedEquipment,
        limit: limit,
        offset: offset,
        sortBy: hasQuery ? 'name' : 'targetMuscles',
        sortOrder: 'asc',
      );

      if (!hasQuery) {
        return response;
      }

      final filteredPlans = response.plans
          .where(
            (WorkoutPlan plan) =>
                plan.name.toLowerCase().contains(trimmedQuery.toLowerCase()),
          )
          .toList(growable: false);

      final metadata = response.metadata?.copyWith(
        totalExercises: filteredPlans.length,
        totalPages: response.metadata?.totalPages ?? 1,
      );

      return response.copyWith(plans: filteredPlans, metadata: metadata);
    }

    final uri = _buildUri('/exercises/search', <String, String?>{
      'q': trimmedQuery,
      'limit': limit.clamp(1, 100).toString(),
      if (offset > 0) 'offset': offset.toString(),
      'threshold': threshold.toStringAsFixed(1),
    });

    final json = await _client.get(uri);
    _ensureSuccess(json);
    return WorkoutPlansResponse.fromJson(json);
  }

  Future<WorkoutPlansResponse> filterExercises({
    String? targetMuscle,
    String? bodyPart,
    String? equipment,
    int limit = 10,
    int offset = 0,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    if ((targetMuscle == null || targetMuscle.isEmpty) &&
        (bodyPart == null || bodyPart.isEmpty) &&
        (equipment == null || equipment.isEmpty)) {
      throw const FormatException(
        'Debes especificar al menos un filtro (músculo objetivo, parte del cuerpo o equipo).',
      );
    }

    final uri = _buildUri('/exercises/filter', <String, String?>{
      if (targetMuscle != null) 'target': targetMuscle.trim(),
      if (bodyPart != null) 'bodyPart': bodyPart.trim(),
      if (equipment != null) 'equipment': equipment.trim(),
      'limit': limit.clamp(1, 100).toString(),
      if (offset > 0) 'offset': offset.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    });

    final json = await _client.get(uri);
    _ensureSuccess(json);
    return WorkoutPlansResponse.fromJson(json);
  }

  Future<WorkoutPlansResponse> fetchByBodyPart(
    String bodyPart, {
    int limit = 10,
    int offset = 0,
  }) async {
    final normalized = bodyPart.trim();
    if (normalized.isEmpty) {
      throw const FormatException('La parte del cuerpo no puede estar vacía.');
    }

    final uri = _buildUri('/bodyparts/$normalized/exercises', <String, String?>{
      'limit': limit.clamp(1, 100).toString(),
      if (offset > 0) 'offset': offset.toString(),
    });

    final json = await _client.get(uri);
    _ensureSuccess(json);
    return WorkoutPlansResponse.fromJson(json);
  }

  Future<WorkoutPlansResponse> fetchByEquipment(
    String equipment, {
    int limit = 10,
    int offset = 0,
  }) async {
    final normalized = equipment.trim();
    if (normalized.isEmpty) {
      throw const FormatException('El nombre del equipo no puede estar vacío.');
    }

    final uri =
        _buildUri('/equipments/$normalized/exercises', <String, String?>{
          'limit': limit.clamp(1, 100).toString(),
          if (offset > 0) 'offset': offset.toString(),
        });

    final json = await _client.get(uri);
    _ensureSuccess(json);
    return WorkoutPlansResponse.fromJson(json);
  }

  Future<WorkoutPlansResponse> fetchByMuscle(
    String muscle, {
    int limit = 10,
    int offset = 0,
    bool includeSecondary = true,
  }) async {
    final normalized = muscle.trim();
    if (normalized.isEmpty) {
      throw const FormatException(
        'El nombre del músculo no puede estar vacío.',
      );
    }

    final uri = _buildUri('/muscles/$normalized/exercises', <String, String?>{
      'limit': limit.clamp(1, 100).toString(),
      if (offset > 0) 'offset': offset.toString(),
      'includeSecondary': includeSecondary.toString(),
    });

    final json = await _client.get(uri);
    _ensureSuccess(json);
    return WorkoutPlansResponse.fromJson(json);
  }

  Future<WorkoutPlan> fetchById(String exerciseId) async {
    final normalized = exerciseId.trim();
    if (normalized.isEmpty) {
      throw const FormatException(
        'El identificador del ejercicio es obligatorio.',
      );
    }

    final uri = _buildUri('/exercises/$normalized');
    final json = await _client.get(uri);
    _ensureSuccess(json);
    return WorkoutPlanDetailResponse.fromJson(json).plan;
  }

  Future<WorkoutAvailableFilters> getAvailableFilters() async {
    if (_cachedFilters != null) {
      return _cachedFilters!;
    }
    const muscles = <String>[
      'abs',
      'chest',
      'back',
      'shoulders',
      'arms',
      'legs',
      'triceps',
      'biceps',
    ];
    const equipments = <String>[
      'body weight',
      'barbell',
      'dumbbell',
      'machine',
      'cable',
    ];
    _cachedFilters = const WorkoutAvailableFilters(
      muscles: muscles,
      equipments: equipments,
    );
    return _cachedFilters!;
  }

  void _ensureSuccess(Map<String, dynamic> json) {
    if (json['success'] == true) {
      return;
    }
    final message =
        json['message']?.toString() ??
        'La API de ejercicios respondió con un error.';
    throw ApiException(message);
  }

  String? _normalizeFilterValue(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.toLowerCase();
  }
}
