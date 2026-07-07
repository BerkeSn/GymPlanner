enum ProgressMetric {
  maxWeight,
  totalVolume,
  estimated1RM,
}

class ExerciseProgressSetModel {
  final int id;
  final int setNumber;
  final int reps;
  final double weight;

  ExerciseProgressSetModel({
    required this.id,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  factory ExerciseProgressSetModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExerciseProgressSetModel(
      id: json['id'],
      setNumber: json['setNumber'],
      reps: json['reps'],
      weight: (json['weight'] as num).toDouble(),
    );
  }
}

class ExerciseProgressEntryModel {
  final int workoutLogId;
  final DateTime date;
  final List<ExerciseProgressSetModel> sets;
  final double maxWeight;
  final double totalVolume;
  final double estimated1RM;

  ExerciseProgressEntryModel({
    required this.workoutLogId,
    required this.date,
    required this.sets,
    required this.maxWeight,
    required this.totalVolume,
    required this.estimated1RM,
  });

  factory ExerciseProgressEntryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExerciseProgressEntryModel(
      workoutLogId: json['workoutLogId'],
      date: DateTime.parse(json['date']),
      sets: (json['sets'] as List)
          .map(
            (s) =>
                ExerciseProgressSetModel.fromJson(
                  s,
                ),
          )
          .toList(),
      maxWeight: (json['maxWeight'] as num)
          .toDouble(),
      totalVolume: (json['totalVolume'] as num)
          .toDouble(),
      estimated1RM: (json['estimated1RM'] as num)
          .toDouble(),
    );
  }
}
