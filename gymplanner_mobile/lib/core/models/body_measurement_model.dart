// lib/core/models/body_measurement_model.dart

class BodyMeasurementModel {
  final DateTime date;
  final double weight;
  final String? goal;

  BodyMeasurementModel({
    required this.date,
    required this.weight,
    this.goal,
  });

  factory BodyMeasurementModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BodyMeasurementModel(
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
      goal: json['goal'],
    );
  }
}
