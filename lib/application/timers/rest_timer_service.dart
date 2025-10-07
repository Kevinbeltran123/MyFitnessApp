import 'dart:async';

import 'package:my_fitness_tracker/domain/timers/rest_timer_entities.dart';

/// Abstraction for scheduling and observing rest timers. Concrete engines can
/// rely on platform services (alarm manager, notifications) while consumers use
/// the simple Dart interface exposed here.
abstract class RestTimerEngine {
  void dispose();
  Stream<RestTimerSnapshot> watch(String key);

  Future<void> schedule(RestTimerRequest request);

  Future<void> pause(String key);

  Future<void> resume(String key);

  Future<void> cancel(String key);
}

/// Coordinates the timer engine and exposes convenience helpers for callers.
class RestTimerManager {
  RestTimerManager({required RestTimerEngine engine}) : _engine = engine;

  static String keyFor(RestTimerRequest request) =>
      _composeKey(request.routineId, request.exerciseId, request.setIndex);

  static String _composeKey(
    String routineId,
    String exerciseId,
    int setIndex,
  ) => [routineId, exerciseId, setIndex.toString()].join('::');

  final RestTimerEngine _engine;

  Stream<RestTimerSnapshot> watch(RestTimerRequest request) =>
      _engine.watch(keyFor(request));

  Stream<RestTimerSnapshot> watchByKey(
    String routineId,
    String exerciseId,
    int setIndex,
  ) => _engine.watch(_composeKey(routineId, exerciseId, setIndex));

  Future<void> start(RestTimerRequest request) => _engine.schedule(request);

  Future<void> pause(RestTimerRequest request) =>
      _engine.pause(keyFor(request));

  Future<void> resume(RestTimerRequest request) =>
      _engine.resume(keyFor(request));

  Future<void> cancel(RestTimerRequest request) =>
      _engine.cancel(keyFor(request));
}

/// Simple in-memory implementation used for development and widget testing. It
/// keeps timers alive while the process is running. Platform-specific
/// integrations can replace this engine by registering a different provider.
class InMemoryRestTimerEngine implements RestTimerEngine {
  InMemoryRestTimerEngine();

  final Map<String, _TimerEntry> _entries = <String, _TimerEntry>{};

  @override
  void dispose() {
    for (final entry in _entries.values) {
      entry.timer?.cancel();
      entry.controller.close();
    }
    _entries.clear();
  }

  @override
  Stream<RestTimerSnapshot> watch(String key) {
    return _ensureEntry(key).controller.stream;
  }

  @override
  Future<void> schedule(RestTimerRequest request) async {
    final String key = RestTimerManager.keyFor(request);
    final _TimerEntry entry = _ensureEntry(key);
    entry.timer?.cancel();

    final DateTime startedAt = DateTime.now();
    entry.snapshot = RestTimerSnapshot(
      status: RestTimerStatus.running,
      elapsed: Duration.zero,
      config: request.config,
      startedAt: startedAt,
    );
    entry.controller.add(entry.snapshot);

    entry.timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final Duration elapsed = DateTime.now().difference(startedAt);
      final RestTimerSnapshot next = entry.snapshot.copyWith(
        elapsed: elapsed,
        status: elapsed >= request.config.target
            ? RestTimerStatus.completed
            : RestTimerStatus.running,
      );
      entry.snapshot = next;
      entry.controller.add(next);
      if (next.isExpired) {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> pause(String key) async {
    final _TimerEntry? entry = _entries[key];
    if (entry == null || entry.snapshot.status != RestTimerStatus.running) {
      return;
    }
    entry.timer?.cancel();
    entry.timer = null;
    entry.snapshot = entry.snapshot.copyWith(
      status: RestTimerStatus.paused,
      pausedAt: DateTime.now(),
    );
    entry.controller.add(entry.snapshot);
  }

  @override
  Future<void> resume(String key) async {
    final _TimerEntry? entry = _entries[key];
    if (entry == null || entry.snapshot.status != RestTimerStatus.paused) {
      return;
    }
    final Duration elapsed = entry.snapshot.elapsed;
    final DateTime resumedAt = DateTime.now();
    entry.snapshot = entry.snapshot.copyWith(
      status: RestTimerStatus.running,
      pausedAt: null,
    );
    entry.controller.add(entry.snapshot);

    entry.timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final Duration nextElapsed =
          elapsed + DateTime.now().difference(resumedAt);
      final RestTimerSnapshot next = entry.snapshot.copyWith(
        elapsed: nextElapsed,
        status: nextElapsed >= entry.snapshot.config.target
            ? RestTimerStatus.completed
            : RestTimerStatus.running,
      );
      entry.snapshot = next;
      entry.controller.add(next);
      if (next.isExpired) {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> cancel(String key) async {
    final _TimerEntry? entry = _entries.remove(key);
    if (entry == null) {
      return;
    }
    entry.timer?.cancel();
    entry.controller.add(
      entry.snapshot.copyWith(status: RestTimerStatus.cancelled),
    );
    await entry.controller.close();
  }

  _TimerEntry _ensureEntry(String key) {
    return _entries.putIfAbsent(key, () {
      return _TimerEntry(
        controller: StreamController<RestTimerSnapshot>.broadcast(),
        snapshot: const RestTimerSnapshot(
          status: RestTimerStatus.idle,
          elapsed: Duration.zero,
          config: RestTimerConfig(target: Duration.zero),
        ),
      );
    });
  }
}

class _TimerEntry {
  _TimerEntry({required this.controller, required this.snapshot});

  final StreamController<RestTimerSnapshot> controller;
  RestTimerSnapshot snapshot;
  Timer? timer;
}
