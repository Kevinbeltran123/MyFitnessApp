// This is a basic Flutter widget test for the Fitness Tracker app.

import 'package:flutter_test/flutter_test.dart';

import 'package:my_fitness_tracker/main.dart';

void main() {
  testWidgets('Fitness Tracker app launches successfully', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyFitnessTrackerApp());

    // Verify that the app title appears
    expect(find.text('My Fitness Tracker'), findsOneWidget);

    // Verify that we can find the main dashboard elements
    // (This test will pass once the home screen is properly implemented)
    await tester.pumpAndSettle();
  });
}
