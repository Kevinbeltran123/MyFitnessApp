import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_fitness_tracker/presentation/navigation/main_navigation.dart';
import 'package:my_fitness_tracker/shared/theme/app_theme.dart';

void main() {
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
      home: const MainNavigation(),
    );
  }
}
