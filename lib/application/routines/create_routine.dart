import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/domain/routines/routine_repository.dart';

class CreateRoutine {
  CreateRoutine(this._repository);

  final RoutineRepository _repository;

  Future<void> call(Routine routine) async {
    if (!routine.hasExercises) {
      throw const FormatException(
        'La rutina debe contener al menos un ejercicio.',
      );
    }
    if (routine.daysOfWeek.isEmpty) {
      throw const FormatException('Selecciona al menos un día para la rutina.');
    }
    await _repository.saveRoutine(routine);
  }
}
