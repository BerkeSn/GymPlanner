// lib/features/workout/screens/workout_detail_screen.dart

import 'package:flutter/material.dart';

class WorkoutDetailScreen
    extends StatelessWidget {
  final int routineId;

  const WorkoutDetailScreen({
    super.key,
    required this.routineId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Detayı'),
      ),
      body: Center(
        child: Text('Routine ID: $routineId'),
      ),
    );
  }
}
