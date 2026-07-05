// lib/core/models/exercise_model.dart

class ExerciseModel {
  final int id;
  final String name;
  final String? description;
  final String? muscleGroupName;
  final String? equipmentName;

  ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    this.muscleGroupName,
    this.equipmentName,
  });

  factory ExerciseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      muscleGroupName:
          json['muscleGroup']?['name'],
      equipmentName: json['equipment']?['name'],
    );
  }
}
