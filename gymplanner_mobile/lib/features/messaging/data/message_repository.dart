import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/conversation_model.dart';
import 'package:gymplanner_mobile/core/models/message_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';
class ChatHistoryResult {
  final List<MessageModel> messages;
  final Map<int, DateTime?>
  participantLastReadAt;

  ChatHistoryResult({
    required this.messages,
    required this.participantLastReadAt,
  });
}

class MessageRepository {
  final Dio _dio = DioClient.instance;

  Future<int> startConversation(
    int friendId,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.startConversation}/$friendId',
      );
      return response.data['conversationId']
          as int;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Sohbet başlatılamadı.';
      throw Exception(message);
    }
  }

  Future<List<ConversationModel>>
  getConversations() async {
    try {
      final response = await _dio.get(
        ApiConstants.getConversations,
      );
      final List data =
          response.data['conversations'] ?? [];
      return data
          .map(
            (e) => ConversationModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Sohbetler alınamadı.';
      throw Exception(message);
    }
  }

  // getMessages fonksiyonunu bununla DEĞİŞTİR:
  Future<ChatHistoryResult> getMessages(
    int conversationId, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getMessages}/$conversationId',
        queryParameters: {
          'page': page,
          'limit': 30,
        },
      );
      final List messagesJson =
          response.data['messages'] ?? [];
      final List participantsJson =
          response.data['participants'] ?? [];

      final messages = messagesJson
          .map((e) => MessageModel.fromJson(e))
          .toList();

      final Map<int, DateTime?> lastReadMap = {
        for (final p in participantsJson)
          p['userId']
              as int: p['lastReadAt'] != null
              ? DateTime.parse(p['lastReadAt'])
              : null,
      };

      return ChatHistoryResult(
        messages: messages,
        participantLastReadAt: lastReadMap,
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Mesajlar alınamadı.';
      throw Exception(message);
    }
  }

  Future<MessageModel> sendMessage({
    required int conversationId,
    required String type,
    String? content,
    String? imageUrl,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.sendMessage}/$conversationId',
        data: {
          'type': type,
          'content': content,
          'imageUrl': imageUrl,
        },
      );
      return MessageModel.fromJson(
        response.data['message'],
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Mesaj gönderilemedi.';
      throw Exception(message);
    }
  }

  Future<bool> markAsRead(
    int conversationId,
  ) async {
    try {
      await _dio.post(
        '${ApiConstants.markAsRead}/$conversationId',
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
