import 'package:gymplanner_mobile/core/models/message_model.dart';

class ConversationParticipantModel {
  final int id;
  final String username;
  final String? name;
  final String? surname;

  ConversationParticipantModel({
    required this.id,
    required this.username,
    this.name,
    this.surname,
  });

  factory ConversationParticipantModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationParticipantModel(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      surname: json['surname'],
    );
  }
}

class ConversationModel {
  final int id;
  final bool isGroup;
  final String? name;
  final List<ConversationParticipantModel>
  participants;
  final MessageModel? lastMessage;
  final bool isUnread;

  ConversationModel({
    required this.id,
    required this.isGroup,
    this.name,
    required this.participants,
    this.lastMessage,
    required this.isUnread,
  });

  factory ConversationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationModel(
      id: json['id'],
      isGroup: json['isGroup'] ?? false,
      name: json['name'],
      participants: (json['participants'] as List)
          .map(
            (p) =>
                ConversationParticipantModel.fromJson(
                  p,
                ),
          )
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(
              json['lastMessage'],
            )
          : null,
      isUnread: json['isUnread'] ?? false,
    );
  }

  /// 1-1 sohbette karşı tarafın adını döner (grup sohbeti geldiğinde name kullanılacak)
  String displayName(int currentUserId) {
    if (isGroup) return name ?? 'Grup';
    final other = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.first,
    );
    final fullName =
        '${other.name ?? ''} ${other.surname ?? ''}'
            .trim();
    return fullName.isNotEmpty
        ? fullName
        : other.username;
  }
}
