class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderUsername;
  final String
  type; // 'text' | 'image' | 'location'
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderUsername,
    required this.type,
    this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      senderUsername:
          json['sender']?['username'] ?? '',
      type: json['type'] ?? 'text',
      content: json['content'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(
        json['createdAt'],
      ),
    );
  }
}
