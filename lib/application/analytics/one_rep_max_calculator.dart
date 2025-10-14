import 'dart:math' as math;

import 'package:my_fitness_tracker/domain/analytics/analytics_entities.dart';

/// Provides helpers to estimate one-repetition maximum (1RM) values using
/// common strength formulas.
class OneRepMaxCalculator {
  const OneRepMaxCalculator({
    this.minValidReps = 1,
    this.maxValidReps = 12,
    this.decimals = 1,
  });

  /// Minimum repetitions allowed for an estimation.
  final int minValidReps;

  /// Maximum repetitions allowed for an estimation.
  final int maxValidReps;

  /// Decimal precision applied to the resulting estimations.
  final int decimals;

  /// Estimates the 1RM for a given set when possible.
  ///
  /// Returns `null` when the provided values fall outside the supported range
  /// (weight <= 0, repetitions outside [minValidReps, maxValidReps], or when
  /// the Brzycki denominator would be zero/negative).
  OneRepMaxEstimate? estimate({
    required double weight,
    required int repetitions,
  }) {
    if (weight <= 0) {
      return null;
    }
    if (repetitions < minValidReps || repetitions > maxValidReps) {
      return null;
    }

    final double epley = _round(weight * (1 + 0.0333 * repetitions));

    final double denominator = 1.0278 - (0.0278 * repetitions);
    if (denominator <= 0) {
      return OneRepMaxEstimate(epley: epley, brzycki: epley);
    }
    final double brzycki = _round(weight / denominator);
    return OneRepMaxEstimate(epley: epley, brzycki: brzycki);
  }

  double _round(double value) {
    final double mod = math.pow(10, decimals).toDouble();
    return (value * mod).roundToDouble() / mod;
  }
}
