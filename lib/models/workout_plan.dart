class WorkoutPlansResponse {
  const WorkoutPlansResponse({
    required this.success,
    required this.plans,
    this.metadata,
  });

  final bool success;
  final WorkoutPaginationMetadata? metadata;
  final List<WorkoutPlan> plans;

  factory WorkoutPlansResponse.fromJson(Map<String, dynamic> json) {
    final bool success = json['success'] as bool? ?? false;
    final metadataJson = json['metadata'];
    final data = json['data'];

    if (data is! List) {
      throw const FormatException('Expected "data" to be a JSON list.');
    }

    return WorkoutPlansResponse(
      success: success,
      metadata: metadataJson is Map<String, dynamic>
          ? WorkoutPaginationMetadata.fromJson(metadataJson)
          : null,
      plans: data
          .map(
            (dynamic item) => WorkoutPlan.fromJson(
              _ensureMap(item, context: 'WorkoutPlansResponse'),
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      if (metadata != null) 'metadata': metadata!.toJson(),
      'data': plans.map((WorkoutPlan plan) => plan.toJson()).toList(),
    };
  }
}

class WorkoutPlanDetailResponse {
  const WorkoutPlanDetailResponse({required this.success, required this.plan});

  final bool success;
  final WorkoutPlan plan;

  factory WorkoutPlanDetailResponse.fromJson(Map<String, dynamic> json) {
    final bool success = json['success'] as bool? ?? false;
    final data = json['data'];
    return WorkoutPlanDetailResponse(
      success: success,
      plan: WorkoutPlan.fromJson(
        _ensureMap(data, context: 'WorkoutPlanDetailResponse'),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'success': success, 'data': plan.toJson()};
  }
}

class WorkoutPaginationMetadata {
  const WorkoutPaginationMetadata({
    required this.totalPages,
    required this.totalExercises,
    required this.currentPage,
    this.previousPage,
    this.nextPage,
  });

  final int totalPages;
  final int totalExercises;
  final int currentPage;
  final Uri? previousPage;
  final Uri? nextPage;

  factory WorkoutPaginationMetadata.fromJson(Map<String, dynamic> json) {
    return WorkoutPaginationMetadata(
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalExercises: (json['totalExercises'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      previousPage: _tryParseUri(json['previousPage']),
      nextPage: _tryParseUri(json['nextPage']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalPages': totalPages,
      'totalExercises': totalExercises,
      'currentPage': currentPage,
      'previousPage': previousPage?.toString(),
      'nextPage': nextPage?.toString(),
    };
  }
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.exerciseId,
    required this.name,
    required this.gifUrl,
    required this.targetMuscles,
    required this.bodyParts,
    required this.equipments,
    required this.secondaryMuscles,
    required this.instructions,
  });

  final String exerciseId;
  final String name;
  final String gifUrl;
  final List<String> targetMuscles;
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final exerciseId = (json['exerciseId'] as String?)?.trim();
    if (exerciseId == null || exerciseId.isEmpty) {
      throw const FormatException('Missing required "exerciseId" field.');
    }

    final name = (json['name'] as String?)?.trim();
    final gifUrl = (json['gifUrl'] as String?)?.trim() ?? '';

    return WorkoutPlan(
      exerciseId: exerciseId,
      name: name == null || name.isEmpty ? 'Sin nombre' : name,
      gifUrl: gifUrl,
      targetMuscles: _parseStringList(json['targetMuscles']),
      bodyParts: _parseStringList(json['bodyParts']),
      equipments: _parseStringList(json['equipments']),
      secondaryMuscles: _parseStringList(json['secondaryMuscles']),
      instructions: _parseStringList(
        json['instructions'],
        fallbackValue: <String>['No hay instrucciones disponibles.'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'exerciseId': exerciseId,
      'name': name,
      'gifUrl': gifUrl,
      'targetMuscles': targetMuscles,
      'bodyParts': bodyParts,
      'equipments': equipments,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
    };
  }

  bool get hasGif => gifUrl.isNotEmpty;

  String get primaryTarget =>
      targetMuscles.isNotEmpty ? targetMuscles.first : 'General';
}

Uri? _tryParseUri(Object? value) {
  if (value is String && value.isNotEmpty) {
    return Uri.tryParse(value);
  }
  return null;
}

Map<String, dynamic> _ensureMap(Object? value, {required String context}) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('$context expected a JSON map.');
}

List<String> _parseStringList(Object? value, {List<String>? fallbackValue}) {
  if (value == null) {
    return fallbackValue ?? <String>[];
  }
  if (value is List) {
    final result = value
        .whereType<String>()
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
    if (result.isEmpty && fallbackValue != null) {
      return fallbackValue;
    }
    return result;
  }
  throw const FormatException('Expected a JSON list of strings.');
}
