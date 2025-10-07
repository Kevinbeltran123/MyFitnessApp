// Domain abstractions for rest timers used during workout sessions.
//
// These models remain framework/platform agnostic. Infrastructure layers are
// expected to provide concrete scheduling/notification behaviour while the
// presentation layer consumes the immutable snapshots emitted here.

// Status of a rest timer lifecycle.
enum RestTimerStatus { idle, running, paused, completed, cancelled }

// Configuration parameters that define how a rest timer should behave.
class RestTimerConfig {
  const RestTimerConfig({
    required this.target,
    this.warningThreshold,
    this.enableVibration = true,
    this.enableNotification = true,
    this.autoStartNextSet = false,
  });

  // Total intended rest duration.
  final Duration target;

  // Optional point at which the user should receive a warning cue.
  final Duration? warningThreshold;

  // Whether haptic feedback should be triggered when the timer completes.
  final bool enableVibration;

  // Whether a local notification should be fired when the timer completes.
  final bool enableNotification;

  // Whether the next set should auto-start when the timer finalises.
  final bool autoStartNextSet;

  RestTimerConfig copyWith({
    Duration? target,
    Duration? warningThreshold,
    bool? enableVibration,
    bool? enableNotification,
    bool? autoStartNextSet,
  }) {
    return RestTimerConfig(
      target: target ?? this.target,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      enableVibration: enableVibration ?? this.enableVibration,
      enableNotification: enableNotification ?? this.enableNotification,
      autoStartNextSet: autoStartNextSet ?? this.autoStartNextSet,
    );
  }
}

// Metadata required to uniquely identify a timer request in the context of a
// routine session.
class RestTimerRequest {
  const RestTimerRequest({
    required this.routineId,
    required this.exerciseId,
    required this.setIndex,
    required this.config,
    this.sessionId,
  });

  final String routineId;
  final String exerciseId;
  final int setIndex;
  final RestTimerConfig config;
  final String? sessionId;

  RestTimerRequest copyWith({
    String? routineId,
    String? exerciseId,
    int? setIndex,
    RestTimerConfig? config,
    String? sessionId,
  }) {
    return RestTimerRequest(
      routineId: routineId ?? this.routineId,
      exerciseId: exerciseId ?? this.exerciseId,
      setIndex: setIndex ?? this.setIndex,
      config: config ?? this.config,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

// Snapshot emitted by the timer engine describing the current progress.
class RestTimerSnapshot {
  const RestTimerSnapshot({
    required this.status,
    required this.elapsed,
    required this.config,
    this.startedAt,
    this.pausedAt,
  });

  final RestTimerStatus status;
  final Duration elapsed;
  final RestTimerConfig config;
  final DateTime? startedAt;
  final DateTime? pausedAt;

  Duration get remaining {
    final remaining = config.target - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isExpired => elapsed >= config.target;

  RestTimerSnapshot copyWith({
    RestTimerStatus? status,
    Duration? elapsed,
    RestTimerConfig? config,
    DateTime? startedAt,
    DateTime? pausedAt,
  }) {
    return RestTimerSnapshot(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      config: config ?? this.config,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }
}
