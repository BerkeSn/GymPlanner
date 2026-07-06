class FriendRequestModel {
  final int friendshipId;
  final int requesterId;
  final String requesterUsername;

  FriendRequestModel({
    required this.friendshipId,
    required this.requesterId,
    required this.requesterUsername,
  });

  factory FriendRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FriendRequestModel(
      friendshipId: json['id'],
      requesterId: json['requesterId'],
      requesterUsername:
          json['requester']?['username'] ??
          'Bilinmeyen',
    );
  }
}
