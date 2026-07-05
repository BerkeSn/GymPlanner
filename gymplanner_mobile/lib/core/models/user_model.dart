class UserModel {
  final int id;
  final String name;
  final String surname;
  final String username;
  final String email;
  final String? phone;
  final String? birthdate;
  final String gender;
  final String locationPreference;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    this.phone,
    this.birthdate,
    required this.gender,
    required this.locationPreference,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      birthdate: json['birthdate'],
      gender: json['gender'] ?? 'other',
      locationPreference:
          json['locationPreference'] ?? 'Gym',
    );
  }
}
