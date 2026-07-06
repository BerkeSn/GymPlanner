// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/network/socket_service.dart';
import 'package:gymplanner_mobile/features/body_measurement/screens/measurement_list_screen.dart';
import 'package:gymplanner_mobile/features/exercise/screens/exercise_list_screen.dart';
import 'package:gymplanner_mobile/features/profile/screens/profile_screen.dart';
import 'package:gymplanner_mobile/features/social/providers/social_provider.dart';
import 'package:gymplanner_mobile/features/workout/screens/workout_list_screen.dart';

import 'features/home/screens/home_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState
    extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WorkoutListScreen(),
    ExerciseListScreen(),
    MeasurementListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToSocialEvents();
    Future.microtask(() {
      ref
          .read(socialProvider.notifier)
          .loadPendingRequests();
    });
  }

  void _listenToSocialEvents() {
    SocketService.instance.on(
      'new_friend_request',
      (data) {
        ref
            .read(socialProvider.notifier)
            .loadPendingRequests();
        _showSnackBar(
          (data is Map
                  ? data['message'] as String?
                  : null) ??
              'Yeni bir arkadaşlık isteğin var!',
        );
      },
    );

    SocketService.instance.on(
      'friend_request_accepted',
      (data) {
        ref
            .read(socialProvider.notifier)
            .loadFriends();
        _showSnackBar(
          (data is Map
                  ? data['message'] as String?
                  : null) ??
              'Bir arkadaşlık isteğin kabul edildi!',
        );
      },
    );

    SocketService.instance.on(
      'friend_request_rejected',
      (data) {
        _showSnackBar(
          (data is Map
                  ? data['message'] as String?
                  : null) ??
              'Arkadaşlık isteğin reddedildi.',
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    SocketService.instance.off(
      'new_friend_request',
    );
    SocketService.instance.off(
      'friend_request_accepted',
    );
    SocketService.instance.off(
      'friend_request_rejected',
    );
    super.dispose();
  }

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
