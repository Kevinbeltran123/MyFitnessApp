import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingCompleteKey = 'onboarding_complete';
const _kProfileSetupCompleteKey = 'profile_setup_complete';

class OnboardingStatus {
  const OnboardingStatus({
    required this.onboardingComplete,
    required this.profileSetupComplete,
  });

  final bool onboardingComplete;
  final bool profileSetupComplete;

  bool get isFullyCompleted => onboardingComplete && profileSetupComplete;
}

final onboardingStatusProvider = FutureProvider<OnboardingStatus>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool(_kOnboardingCompleteKey) ?? false;
  final profileComplete = prefs.getBool(_kProfileSetupCompleteKey) ?? false;
  return OnboardingStatus(
    onboardingComplete: onboardingComplete,
    profileSetupComplete: profileComplete,
  );
});

final onboardingPersistenceProvider = Provider<OnboardingPersistence>((ref) {
  return const OnboardingPersistence();
});

class OnboardingPersistence {
  const OnboardingPersistence();

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingCompleteKey, true);
  }

  Future<void> markProfileSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kProfileSetupCompleteKey, true);
  }
}
