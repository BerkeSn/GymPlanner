class FriendModel {
  final int id;
  final String username;

  FriendModel({
    required this.id,
    required this.username,
  });

  factory FriendModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FriendModel(
      id: json['id'],
      username: json['username'],
    );
  }
}
