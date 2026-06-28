// lib/core/models/workout_routine_detail_model.dart

import 'package:gymplanner_mobile/core/models/routine_exercise_model.dart';

class WorkoutRoutineDetailModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final List<RoutineExerciseModel> exercises;
  final DateTime? createdAt;

  WorkoutRoutineDetailModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.exercises,
    required this.createdAt,
  });

  factory WorkoutRoutineDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkoutRoutineDetailModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      exercises:
          (json['routineExercises']
                  as List<dynamic>)
              .map(
                (exerciseJson) =>
                    RoutineExerciseModel.fromJson(
                      exerciseJson,
                    ),
              )
              .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
