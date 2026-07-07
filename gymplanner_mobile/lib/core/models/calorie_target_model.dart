class CalorieTargetModel {
  final int bmr;
  final int tdee;
  final String goal;
  final String activityLevel;
  final int targetCalories;

  CalorieTargetModel({
    required this.bmr,
    required this.tdee,
    required this.goal,
    required this.activityLevel,
    required this.targetCalories,
  });

  factory CalorieTargetModel.fromJson(Map<String, dynamic> json) {
    return CalorieTargetModel(
      bmr: json['bmr'],
      tdee: json['tdee'],
      goal: json['goal'],
      activityLevel: json['activityLevel'],
      targetCalories: json['targetCalories'],
    );
  }
}