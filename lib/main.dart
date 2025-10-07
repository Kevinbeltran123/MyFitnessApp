import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_fitness_tracker/screens/home_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent.shade400,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
