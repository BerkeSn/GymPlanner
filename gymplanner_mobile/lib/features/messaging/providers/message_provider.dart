import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/conversation_model.dart';
import 'package:gymplanner_mobile/core/models/message_model.dart';
import 'package:gymplanner_mobile/core/network/socket_service.dart';
import 'package:gymplanner_mobile/features/messaging/data/message_repository.dart';

final messageRepositoryProvider =
    Provider<MessageRepository>(
      (ref) => MessageRepository(),
    );

class ConversationListState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? errorMessage;

  const ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ConversationListState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConversationListState(
      conversations:
          conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ConversationListNotifier
    extends StateNotifier<ConversationListState> {
  final MessageRepository _repository;

  ConversationListNotifier(this._repository)
    : super(const ConversationListState()) {
    SocketService.instance.on(
      'new_message',
      _onSocketUpdate,
    );
    SocketService.instance.on(
      'message_read',
      _onSocketUpdate,
    );
    loadConversations();
  }

  void _onSocketUpdate(dynamic data) =>
      loadConversations();

  Future<void> loadConversations() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    try {
      final conversations = await _repository
          .getConversations();
      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  /// Arkadaş listesinden "mesaj gönder" tıklanınca çağrılır.
  Future<int?> startConversationWith(
    int friendId,
  ) async {
    try {
      final conversationId = await _repository
          .startConversation(friendId);
      await loadConversations();
      return conversationId;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return null;
    }
  }

  @override
  void dispose() {
    SocketService.instance.off(
      'new_message',
      _onSocketUpdate,
    );
    SocketService.instance.off(
      'message_read',
      _onSocketUpdate,
    );
    super.dispose();
  }
}

final conversationListProvider =
    StateNotifierProvider<
      ConversationListNotifier,
      ConversationListState
    >(
      (ref) => ConversationListNotifier(
        ref.watch(messageRepositoryProvider),
      ),
    );

// ------------------------------------------------------------
// Tek Sohbet (Mesaj Akışı)
// ------------------------------------------------------------

class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final bool isOtherUserTyping;
  final DateTime? otherUserLastReadAt;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isOtherUserTyping = false,
    this.otherUserLastReadAt,
    this.errorMessage,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isOtherUserTyping,
    DateTime? otherUserLastReadAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isOtherUserTyping:
          isOtherUserTyping ??
          this.isOtherUserTyping,
      otherUserLastReadAt:
          otherUserLastReadAt ??
          this.otherUserLastReadAt,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatNotifier
    extends StateNotifier<ChatState> {
  final MessageRepository _repository;
  final int conversationId;
  final int otherUserId;

  ChatNotifier(
    this._repository,
    this.conversationId,
    this.otherUserId,
  ) : super(const ChatState()) {
    SocketService.instance.on(
      'new_message',
      _onNewMessage,
    );
    SocketService.instance.on(
      'typing',
      _onTyping,
    );
    SocketService.instance.on(
      'message_read',
      _onMessageRead,
    );
    loadMessages();
  }

  void _onNewMessage(dynamic data) {
    if (data['conversationId'] ==
        conversationId) {
      final incoming = MessageModel.fromJson(
        data['message'],
      );
      // Kendi gönderdiğimiz mesajı socket echo'sundan tekrar eklememek için kontrol
      final alreadyExists = state.messages.any(
        (m) => m.id == incoming.id,
      );
      if (!alreadyExists) {
        state = state.copyWith(
          messages: [...state.messages, incoming],
        );
      }
      _repository.markAsRead(conversationId);
    }
  }

  void _onTyping(dynamic data) {
    if (data['conversationId'] ==
        conversationId) {
      state = state.copyWith(
        isOtherUserTyping: true,
      );
      Future.delayed(
        const Duration(seconds: 3),
        () {
          if (mounted)
            state = state.copyWith(
              isOtherUserTyping: false,
            );
        },
      );
    }
  }

  void _onMessageRead(dynamic data) {
    if (data['conversationId'] ==
            conversationId &&
        data['readerId'] == otherUserId) {
      final readAt = data['readAt'] != null
          ? DateTime.parse(data['readAt'])
          : DateTime.now();
      state = state.copyWith(
        otherUserLastReadAt: readAt,
      );
    }
  }
/*
Future<void> loadMessages() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    try {
      final messages = await _repository
          .getMessages(conversationId);
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
      await _repository.markAsRead(
        conversationId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }
  */

Future<void> loadMessages() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    try {
      final chatHistory = await _repository
          .getMessages(conversationId);

      final otherUserReadAt = chatHistory
          .participantLastReadAt[otherUserId];

      state = state.copyWith(
        messages: chatHistory
            .messages,
        otherUserLastReadAt:
            otherUserReadAt,
        isLoading: false,
      );

      await _repository.markAsRead(
        conversationId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<bool> sendTextMessage(
    String content,
  ) async {
    if (content.trim().isEmpty) return false;
    state = state.copyWith(
      isSending: true,
      clearError: true,
    );
    try {
      final message = await _repository
          .sendMessage(
            conversationId: conversationId,
            type: 'text',
            content: content.trim(),
          );
      state = state.copyWith(
        messages: [...state.messages, message],
        isSending: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }

  void notifyTyping(int receiverId) {
    SocketService.instance.emit('typing', {
      'conversationId': conversationId,
      'receiverId': receiverId,
    });
  }

  @override
  void dispose() {
    SocketService.instance.off(
      'new_message',
      _onNewMessage,
    );
    SocketService.instance.off(
      'typing',
      _onTyping,
    );
    SocketService.instance.off(
      'message_read',
      _onMessageRead,
    );
    super.dispose();
  }
}

final chatProvider =
    StateNotifierProvider.family<
      ChatNotifier,
      ChatState,
      ({int conversationId, int otherUserId})
    >(
      (ref, args) => ChatNotifier(
        ref.watch(messageRepositoryProvider),
        args.conversationId,
        args.otherUserId,
      ),
    );
