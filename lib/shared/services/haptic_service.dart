import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

/// Lightweight wrapper around the `vibration` plugin so the haptic logic can
/// be unit-tested by injecting a fake dependency.
class VibrationAdapter {
  const VibrationAdapter();

  Future<bool?> hasVibrator() => Vibration.hasVibrator();

  Future<bool?> hasAmplitudeControl() => Vibration.hasAmplitudeControl();

  Future<bool?> hasCustomVibrationsSupport() =>
      Vibration.hasCustomVibrationsSupport();

  Future<void> vibrate({int? duration, int? amplitude}) {
    if (amplitude != null) {
      if (duration != null) {
        return Vibration.vibrate(duration: duration, amplitude: amplitude);
      }
      return Vibration.vibrate(amplitude: amplitude);
    }
    if (duration != null) {
      return Vibration.vibrate(duration: duration);
    }
    return Vibration.vibrate();
  }
}

/// Provides simple, preference-aware access to haptic feedback.
///
/// The service guards against unavailable hardware (e.g. simulators or web)
/// and falls back gracefully when fine-grained amplitude control is not
/// supported by the platform.
class HapticService {
  HapticService({VibrationAdapter? adapter})
    : _adapter = adapter ?? const VibrationAdapter();

  final VibrationAdapter _adapter;
  bool? _supportsHaptics;
  bool? _supportsCustomAmplitude;

  /// Light feedback, used for small UI nudges.
  Future<void> light() => _trigger(duration: 12, amplitude: 60);

  /// Medium feedback, intended for confirmations.
  Future<void> medium() => _trigger(duration: 20, amplitude: 140);

  /// Heavy feedback, suitable for celebratory actions.
  Future<void> heavy() => _trigger(duration: 35, amplitude: 255);

  Future<void> _trigger({required int duration, required int amplitude}) async {
    if (kIsWeb) {
      return;
    }
    if (!await _hasHapticSupport()) {
      return;
    }
    final bool customAmplitude = await _hasCustomAmplitude();
    if (customAmplitude) {
      await _adapter.vibrate(duration: duration, amplitude: amplitude);
    } else {
      await _adapter.vibrate(duration: duration);
    }
  }

  Future<bool> _hasHapticSupport() async {
    if (_supportsHaptics != null) {
      return _supportsHaptics!;
    }
    final bool? hasVibrator = await _adapter.hasVibrator();
    _supportsHaptics = hasVibrator ?? false;
    return _supportsHaptics!;
  }

  Future<bool> _hasCustomAmplitude() async {
    if (_supportsCustomAmplitude != null) {
      return _supportsCustomAmplitude!;
    }
    final bool? hasAmplitude = await _adapter.hasAmplitudeControl();
    if (hasAmplitude == true) {
      _supportsCustomAmplitude = true;
      return true;
    }
    final bool? hasCustomSupport = await _adapter.hasCustomVibrationsSupport();
    _supportsCustomAmplitude = hasCustomSupport ?? false;
    return _supportsCustomAmplitude!;
  }
}

/// Global provider so presentation layer widgets can trigger haptic feedback.
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});
