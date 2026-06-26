// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:gymplanner_mobile/features/body_measurement/screens/measurement_list_screen.dart';
import 'package:gymplanner_mobile/features/exercise/screens/exercise_list_screen.dart';
import 'package:gymplanner_mobile/features/profile/screens/profile_screen.dart';
import 'package:gymplanner_mobile/features/workout/screens/workout_list_screen.dart';

import 'features/home/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WorkoutListScreen(),
    ExerciseListScreen(),
    MeasurementListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center_outlined,
            ),
            activeIcon: Icon(
              Icons.fitness_center,
            ),
            label: 'Antrenman',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.sports_gymnastics_outlined,
            ),
            activeIcon: Icon(
              Icons.sports_gymnastics,
            ),
            label: 'Egzersizler',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.monitor_weight_outlined,
            ),
            activeIcon: Icon(
              Icons.monitor_weight,
            ),
            label: 'Ölçümler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
