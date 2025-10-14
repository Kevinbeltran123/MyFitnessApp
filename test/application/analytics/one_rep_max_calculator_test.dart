import 'package:flutter_test/flutter_test.dart';
import 'package:my_fitness_tracker/application/analytics/one_rep_max_calculator.dart';

void main() {
  group('OneRepMaxCalculator', () {
    const calculator = OneRepMaxCalculator();

    test('calculates Epley and Brzycki estimates with expected precision', () {
      final result = calculator.estimate(weight: 100, repetitions: 5);
      expect(result, isNotNull);
      expect(result!.epley, closeTo(116.7, 0.05));
      expect(result.brzycki, closeTo(112.5, 0.05));
      expect(result.average, closeTo(114.6, 0.05));
    });

    test('returns null when weight is zero or negative', () {
      expect(calculator.estimate(weight: 0, repetitions: 5), isNull);
      expect(calculator.estimate(weight: -20, repetitions: 5), isNull);
    });

    test('returns null when repetitions fall outside supported range', () {
      expect(calculator.estimate(weight: 80, repetitions: 0), isNull);
      expect(calculator.estimate(weight: 80, repetitions: 15), isNull);
    });

    test('handles Brzycki denominator edge cases gracefully', () {
      // For 12 reps the denominator stays positive but close to zero.
      final result = calculator.estimate(weight: 60, repetitions: 12);
      expect(result, isNotNull);
      expect(result!.brzycki.isFinite, isTrue);
      expect(result.epley.isFinite, isTrue);
    });
  });
}
