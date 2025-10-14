// This is a basic Flutter widget test for the Fitness Tracker app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_fitness_tracker/application/analytics/one_rep_max_calculator.dart';
import 'package:my_fitness_tracker/application/analytics/personal_record_service.dart';
import 'package:my_fitness_tracker/main.dart';
import 'package:my_fitness_tracker/presentation/analytics/analytics_providers.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_controller.dart';
import 'package:my_fitness_tracker/services/api_client.dart';
import 'package:my_fitness_tracker/services/workout_service.dart';
import 'support/fake_session_repository.dart';

void main() {
  testWidgets('Fitness Tracker app launches successfully', (
    WidgetTester tester,
  ) async {
    final fakeClient = _FakeApiClient();
    final fakeSessionRepository = FakeSessionRepository();
    final fakePersonalRecordService = PersonalRecordService(
      sessionRepository: fakeSessionRepository,
      calculator: const OneRepMaxCalculator(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          apiClientProvider.overrideWithValue(fakeClient),
          workoutServiceProvider.overrideWithValue(WorkoutService(fakeClient)),
          sessionRepositoryProvider.overrideWith(
            (ref) async => fakeSessionRepository,
          ),
          personalRecordServiceProvider.overrideWith(
            (ref) async => fakePersonalRecordService,
          ),
        ],
        child: const MyFitnessTrackerApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that the home greeting renders
    expect(find.text('Hola! 👋'), findsOneWidget);
  });
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient();

  @override
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    return <String, dynamic>{
      'success': true,
      'data': <Map<String, dynamic>>[
        <String, dynamic>{
          'exerciseId': 'test-exercise',
          'name': 'Sentadilla con peso corporal',
          'gifUrl': '',
          'targetMuscles': <String>['legs'],
          'bodyParts': <String>['lower body'],
          'equipments': <String>['none'],
          'secondaryMuscles': <String>['core'],
          'instructions': <String>[
            'Calienta antes de comenzar',
            'Mantén la espalda recta durante todo el movimiento',
          ],
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    return <String, dynamic>{'success': true, 'data': <String, dynamic>{}};
  }

  @override
  void close() {
    // No resources to dispose in the fake client.
  }
}
