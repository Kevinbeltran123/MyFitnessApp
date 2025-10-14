import 'dart:async';

import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';

class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository() {
    _controller.onListen = () => _controller.add(_sessions);
  }

  final List<RoutineSession> _sessions = <RoutineSession>[];
  final StreamController<List<RoutineSession>> _controller =
      StreamController<List<RoutineSession>>.broadcast();

  void setSessions(Iterable<RoutineSession> sessions) {
    _sessions
      ..clear()
      ..addAll(sessions);
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List<RoutineSession>.unmodifiable(_sessions));
    }
  }

  @override
  Future<void> saveSession(RoutineSession session) async {
    final index = _sessions.indexWhere((element) => element.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.add(session);
    }
    _emit();
  }

  @override
  Future<List<RoutineSession>> getAllSessions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _filterByDateRange(_sessions, startDate, endDate);
  }

  @override
  Future<List<RoutineSession>> getSessionsByRoutine(String routineId) async {
    return _sessions.where((session) => session.routineId == routineId).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<RoutineSession?> getLatestSession() async {
    if (_sessions.isEmpty) {
      return null;
    }
    return _sessions.reduce((a, b) => a.startedAt.isAfter(b.startedAt) ? a : b);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
    _emit();
  }

  @override
  Stream<List<RoutineSession>> watchSessions({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate == null && endDate == null) {
      return _controller.stream;
    }
    return _controller.stream.map(
      (sessions) => _filterByDateRange(sessions, startDate, endDate),
    );
  }

  List<RoutineSession> _filterByDateRange(
    Iterable<RoutineSession> sessions,
    DateTime? start,
    DateTime? end,
  ) {
    return sessions.where((session) {
      final bool afterStart =
          start == null || !session.startedAt.isBefore(start);
      final bool beforeEnd = end == null || !session.startedAt.isAfter(end);
      return afterStart && beforeEnd;
    }).toList();
  }
}
