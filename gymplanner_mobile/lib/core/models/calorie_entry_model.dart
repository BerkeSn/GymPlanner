class CalorieEntryModel {
  final DateTime date;
  final int calories;

  CalorieEntryModel({
    required this.date,
    required this.calories,
  });

  factory CalorieEntryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CalorieEntryModel(
      date: DateTime.parse(json['date']),
      calories: json['calories'],
    );
  }
}
