import 'package:collection/collection.dart';
import 'package:my_fitness_tracker/application/analytics/one_rep_max_calculator.dart';
import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';

/// Service responsible for deriving personal records (PRs) from logged sessions.
class PersonalRecordService {
  PersonalRecordService({
    required SessionRepository sessionRepository,
    OneRepMaxCalculator? calculator,
  }) : _sessionRepository = sessionRepository,
       _calculator = calculator ?? const OneRepMaxCalculator();

  final SessionRepository _sessionRepository;
  final OneRepMaxCalculator _calculator;

  /// Watches personal records for all exercises, recomputing whenever sessions
  /// data changes.
  Stream<List<PersonalRecord>> watchPersonalRecords() async* {
    await for (final sessions in _sessionRepository.watchSessions()) {
      yield _computeRecords(sessions);
    }
  }

  /// Watches the personal record for a specific exercise.
  Stream<PersonalRecord?> watchRecordByExercise(String exerciseId) {
    return watchPersonalRecords().map(
      (records) =>
          records.firstWhereOrNull((record) => record.exerciseId == exerciseId),
    );
  }

  /// Calculates personal records from the currently stored sessions.
  Future<List<PersonalRecord>> loadPersonalRecords() async {
    final sessions = await _sessionRepository.getAllSessions();
    return _computeRecords(sessions);
  }

  List<PersonalRecord> _computeRecords(List<RoutineSession> sessions) {
    final Map<String, PersonalRecord> bestByExercise =
        <String, PersonalRecord>{};

    for (final session in sessions) {
      for (final log in session.exerciseLogs) {
        for (final set in log.setLogs) {
          final OneRepMaxEstimate? estimate = _calculator.estimate(
            weight: set.weight,
            repetitions: set.repetitions,
          );
          if (estimate == null) {
            continue;
          }

          final PersonalRecord candidate = PersonalRecord(
            exerciseId: log.exerciseId,
            oneRepMax: estimate.average,
            bestWeight: set.weight,
            repetitions: set.repetitions,
            achievedAt: session.completedAt,
            sessionId: session.id,
            setNumber: set.setNumber,
          );

          final PersonalRecord? current = bestByExercise[log.exerciseId];
          if (_shouldReplace(current, candidate)) {
            bestByExercise[log.exerciseId] = candidate;
          }
        }
      }
    }

    final List<PersonalRecord> records = bestByExercise.values.toList()
      ..sort((a, b) => b.oneRepMax.compareTo(a.oneRepMax));
    return records;
  }

  bool _shouldReplace(PersonalRecord? current, PersonalRecord candidate) {
    if (current == null) {
      return true;
    }
    if (candidate.oneRepMax > current.oneRepMax + 1e-6) {
      return true;
    }
    if ((candidate.oneRepMax - current.oneRepMax).abs() <= 1e-6) {
      if (candidate.bestWeight > current.bestWeight + 1e-6) {
        return true;
      }
      if ((candidate.bestWeight - current.bestWeight).abs() <= 1e-6 &&
          candidate.achievedAt.isAfter(current.achievedAt)) {
        return true;
      }
    }
    return false;
  }
}
