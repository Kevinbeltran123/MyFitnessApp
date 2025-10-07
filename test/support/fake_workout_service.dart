import 'package:my_fitness_tracker/models/workout_plan.dart';
import 'package:my_fitness_tracker/services/api_client.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';

class FakeWorkoutService extends WorkoutService {
  FakeWorkoutService() : super(ApiClient());

  WorkoutPlansResponse _response() {
    return const WorkoutPlansResponse(
      success: true,
      metadata: null,
      plans: <WorkoutPlan>[
        WorkoutPlan(
          exerciseId: 'push-up',
          name: 'Push Ups',
          gifUrl: '',
          targetMuscles: <String>['Chest'],
          bodyParts: <String>['Upper'],
          equipments: <String>['Bodyweight'],
          secondaryMuscles: <String>['Triceps'],
          instructions: <String>['Mantén postura neutra'],
        ),
      ],
    );
  }

  @override
  Future<WorkoutPlansResponse> fetchExercises({
    int limit = 10,
    int offset = 0,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    return _response();
  }

  @override
  Future<WorkoutPlansResponse> searchExercises(
    String query, {
    String? muscle,
    String? equipment,
    int limit = 10,
    int offset = 0,
    double threshold = 0.3,
  }) async {
    return _response();
  }
}
