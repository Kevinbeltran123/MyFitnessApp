import 'package:collection/collection.dart';

/// Category that groups achievements by the type of behaviour they encourage.
enum AchievementType { routine, workout, metric, streak, personalRecord }

/// Represents an achievement definition plus the user's current progress.
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.targetValue,
    this.currentValue = 0,
    this.unlockedAt,
    this.badgeColor,
    this.isSecret = false,
  });

  /// Unique identifier used to reference the achievement internally.
  final String id;

  /// Localised display name shown to the user.
  final String name;

  /// Short description explaining what needs to be done to unlock it.
  final String description;

  /// Category that owns this achievement.
  final AchievementType type;

  /// Icon asset or identifier; UI layer decides how to resolve it.
  final String icon;

  /// Optional accent colour for the badge (hex string, e.g. '#FF9800').
  final String? badgeColor;

  /// Whether the achievement should be hidden until unlocked.
  final bool isSecret;

  /// Date when the achievement was unlocked (if applicable).
  final DateTime? unlockedAt;

  /// Numeric goal associated with the achievement. Interpret units based on [type].
  final double targetValue;

  /// Current progress accumulated towards [targetValue].
  final double currentValue;

  /// Returns true when the achievement has been unlocked.
  bool isUnlocked() => unlockedAt != null || currentValue >= targetValue;

  /// Returns progress ratio between 0.0 and 1.0.
  double progress() {
    if (targetValue <= 0) {
      return isUnlocked() ? 1 : 0;
    }
    final double ratio = currentValue / targetValue;
    return ratio.clamp(0, 1);
  }

  /// Helper that normalises progress for achievements with boolean state.
  Achievement updateProgress(double value, {DateTime? unlockedAt}) {
    final double nextValue = value.isNaN ? 0 : value;
    final bool unlocked = unlockedAt != null || nextValue >= targetValue;
    return copyWith(
      currentValue: nextValue,
      unlockedAt: unlocked
          ? (unlockedAt ?? this.unlockedAt ?? DateTime.now())
          : this.unlockedAt,
    );
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    AchievementType? type,
    String? icon,
    double? targetValue,
    double? currentValue,
    DateTime? unlockedAt,
    bool setUnlockedAtNull = false,
    String? badgeColor,
    bool? isSecret,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      badgeColor: badgeColor ?? this.badgeColor,
      isSecret: isSecret ?? this.isSecret,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unlockedAt: setUnlockedAtNull ? null : (unlockedAt ?? this.unlockedAt),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Immutable definition describing how to unlock an achievement.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.targetValue,
    this.badgeColor,
    this.isSecret = false,
  });

  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final String icon;
  final double targetValue;
  final String? badgeColor;
  final bool isSecret;

  Achievement createInstance({double currentValue = 0, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      type: type,
      icon: icon,
      badgeColor: badgeColor,
      isSecret: isSecret,
      targetValue: targetValue,
      currentValue: currentValue,
      unlockedAt: unlockedAt,
    );
  }
}

typedef AchievementCatalog = List<AchievementDefinition>;

extension AchievementDefinitionListX on AchievementCatalog {
  Map<String, AchievementDefinition> asIndex() => {
    for (final definition in this) definition.id: definition,
  };

  AchievementDefinition? byId(String id) =>
      firstWhereOrNull((def) => def.id == id);
}
