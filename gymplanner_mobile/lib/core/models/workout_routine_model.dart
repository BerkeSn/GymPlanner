// lib/core/models/workout_routine_model.dart

class WorkoutRoutineModel {
  final int id;
  final String name;
  final List<String> days;

  WorkoutRoutineModel({
    required this.id,
    required this.name,
    required this.days,
  });

  factory WorkoutRoutineModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkoutRoutineModel(
      id: json['id'],
      name: json['name'],
      days: (json['routineExercises'] as List)
          .map((e) => e['day'] as String)
          .toList(),
    );
  }
}