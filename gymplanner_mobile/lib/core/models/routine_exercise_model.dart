// lib/core/models/workout_routine_detail_model.dart

class RoutineExerciseModel {
  final int id;
  final String day;
  final int targetSets;
  final int targetReps;
  final String? exerciseName;
  final int? exerciseId;

  RoutineExerciseModel({
    required this.id,
    required this.day,
    required this.targetSets,
    required this.targetReps,
    this.exerciseName,
    this.exerciseId,
  });

  factory RoutineExerciseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RoutineExerciseModel(
      id: json['id'],
      day: json['day'],
      targetSets: json['targetSets'],
      targetReps: json['targetReps'],
      exerciseName: json['exercise']?['name'],
      exerciseId: json['exercise']?['id']
    );
  }
}