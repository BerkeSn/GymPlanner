// lib/core/models/workout_log_model.dart

class WorkoutLogModel {
  final int id;
  final DateTime date;
  final String? routineName;

  WorkoutLogModel({
    required this.id,
    required this.date,
    this.routineName,
  });

  factory WorkoutLogModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkoutLogModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      routineName:
          json['workoutRoutine']?['name'],
    );
  }
}
