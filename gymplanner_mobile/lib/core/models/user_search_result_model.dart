class UserSearchResultModel {
  final int id;
  final String username;
  final String name;
  final String surname;

  UserSearchResultModel({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
  });

  factory UserSearchResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserSearchResultModel(
      id: json['id'],
      username: json['username'],
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
    );
  }
}
