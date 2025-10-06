class NutritionEntry {
  const NutritionEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.macros,
    required this.loggedAt,
  });

  final String id;
  final String name;
  final int calories;
  final Map<String, num> macros;
  final DateTime loggedAt;

  factory NutritionEntry.fromJson(Map<String, dynamic> json) {
    return NutritionEntry(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown item',
      calories: (json['calories'] as num?)?.round() ?? 0,
      macros: Map<String, num>.from(json['macros'] as Map? ?? <String, num>{}),
      loggedAt:
          DateTime.tryParse(json['loggedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'calories': calories,
      'macros': macros,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }
}
