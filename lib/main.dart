import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_fitness_tracker/presentation/navigation/main_navigation.dart';
import 'package:my_fitness_tracker/presentation/onboarding/onboarding_screen.dart';
import 'package:my_fitness_tracker/presentation/onboarding/onboarding_state.dart';
import 'package:my_fitness_tracker/presentation/onboarding/profile_setup_screen.dart';
import 'package:my_fitness_tracker/presentation/metrics/widgets/quick_weight_logger_dialog.dart';
import 'package:my_fitness_tracker/shared/services/notification_service.dart';
import 'package:my_fitness_tracker/shared/theme/app_theme.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyFitnessTrackerApp()));
}

class MyFitnessTrackerApp extends StatelessWidget {
  const MyFitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: rootNavigatorKey,
      home: const _RootRouter(),
    );
  }
}

class _RootRouter extends ConsumerWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationServiceProvider);

    ref.listen<NotificationQuickAction?>(notificationQuickActionProvider, (
      previous,
      next,
    ) async {
      if (next == null) return;
      final BuildContext targetContext =
          rootNavigatorKey.currentContext ?? context;
      await showQuickWeightLoggerDialog(targetContext, ref);
      ref.read(notificationQuickActionProvider.notifier).clear();
    });

    final onboardingAsync = ref.watch(onboardingStatusProvider);

    return onboardingAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(
            'Ocurrió un error al cargar configuración inicial\n$error',
          ),
        ),
      ),
      data: (status) {
        if (!status.onboardingComplete) {
          return const OnboardingScreen(key: ValueKey('onboarding'));
        }
        if (!status.profileSetupComplete) {
          return ProfileSetupScreen(
            key: const ValueKey('profile_setup'),
            onCompleted: (_) {
              ref.invalidate(onboardingStatusProvider);
            },
          );
        }
        return const MainNavigation();
      },
    );
  }
}
