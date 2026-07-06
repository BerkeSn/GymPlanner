// lib/core/models/body_measurement_model.dart

class BodyMeasurementModel {
  final int id;
  final DateTime date;
  final double weight;
  final double height;
  final double? neck;
  final double? waist;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final String? goal;

  BodyMeasurementModel({
    required this.id,
    required this.date,
    required this.weight,
    required this.height,
    this.neck,
    this.waist,
    this.bodyFatPercentage,
    this.muscleMass,
    this.goal,
  });

  factory BodyMeasurementModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BodyMeasurementModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      neck: json['neck'] != null
          ? (json['neck'] as num).toDouble()
          : null,
      waist: json['waist'] != null
          ? (json['waist'] as num).toDouble()
          : null,
      bodyFatPercentage:
          json['bodyFatPercentage'] != null
          ? (json['bodyFatPercentage'] as num)
                .toDouble()
          : null,
      muscleMass: json['muscleMass'] != null
          ? (json['muscleMass'] as num).toDouble()
          : null,
      goal: json['goal'],
    );
  }
}
