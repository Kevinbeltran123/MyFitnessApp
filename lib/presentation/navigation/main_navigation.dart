import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/presentation/profile/profile_screen.dart';
import 'package:my_fitness_tracker/presentation/routines/routine_list_screen.dart';
import 'package:my_fitness_tracker/presentation/workouts/workout_history_screen.dart';
import 'package:my_fitness_tracker/screens/exercises_screen.dart';
import 'package:my_fitness_tracker/screens/home_screen.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Main navigation widget with bottom tab bar
///
/// Provides navigation between the 5 main sections of the app:
/// - Home: Dashboard with daily summary
/// - Entrenamientos: Workout history and active sessions
/// - Rutinas: Routine management
/// - Ejercicios: Exercise explorer
/// - Más: Profile and settings
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Define all screens
  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    WorkoutHistoryScreen(),
    RoutineListScreen(),
    ExercisesScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 72,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Entrenamientos',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Rutinas',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Ejercicios',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}
