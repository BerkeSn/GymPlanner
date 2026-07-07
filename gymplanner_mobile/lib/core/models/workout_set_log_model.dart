class WorkoutSetLogModel {
  final int id;
  final int exerciseId;
  final int setNumber;
  final int reps;
  final double weight;

  WorkoutSetLogModel({
    required this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  factory WorkoutSetLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSetLogModel(
      id: json['id'],
      exerciseId: json['exerciseId'],
      setNumber: json['setNumber'],
      reps: json['reps'],
      weight: (json['weight'] as num).toDouble(),
    );
  }
}