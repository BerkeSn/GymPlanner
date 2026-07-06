import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/models/message_model.dart';
import 'package:gymplanner_mobile/features/auth/providers/auth_provider.dart';
import 'package:gymplanner_mobile/features/messaging/providers/message_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final int otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  ConsumerState<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingDebounce;

  ({int conversationId, int otherUserId})
  get _providerKey => (
    conversationId: widget.conversationId,
    otherUserId: widget.otherUserId,
  );

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onTextChanged(String _) {
    _typingDebounce?.cancel();
    _typingDebounce = Timer(
      const Duration(milliseconds: 400),
      () {
        ref
            .read(
              chatProvider(_providerKey).notifier,
            )
            .notifyTyping(widget.otherUserId);
      },
    );
  }

  Future<void> _send() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    final success = await ref
        .read(chatProvider(_providerKey).notifier)
        .sendTextMessage(text);
    if (success) {
      WidgetsBinding.instance
          .addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
    }
  }

  int _resolveUserId(Map<String, dynamic>? user) {
    final id = user?['id'];
    if (id is int) return id;
    if (id is String)
      return int.tryParse(id) ?? -1;
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      chatProvider(_providerKey),
    );
    final currentUserId = _resolveUserId(
      ref.watch(authProvider).user,
    );

    ref.listen(chatProvider(_providerKey), (
      previous,
      next,
    ) {
      if (previous != null &&
          next.messages.length >
              previous.messages.length) {
        WidgetsBinding.instance
            .addPostFrameCallback(
              (_) => _scrollToBottom(),
            );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        bottom: state.isOtherUserTyping
            ? const PreferredSize(
                preferredSize: Size.fromHeight(
                  20,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 6,
                  ),
                  child: Text(
                    'yazıyor...',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(
              state,
              currentUserId,
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    ChatState state,
    int currentUserId,
  ) {
    if (state.isLoading &&
        state.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state.errorMessage != null &&
        state.messages.isEmpty) {
      return Center(
        child: Text(state.errorMessage!),
      );
    }
    if (state.messages.isEmpty) {
      return const Center(
        child: Text(
          'Henüz mesaj yok, ilk mesajı sen gönder!',
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isMine =
            message.senderId == currentUserId;
        final isRead =
            isMine &&
            state.otherUserLastReadAt != null &&
            !message.createdAt.isAfter(
              state.otherUserLastReadAt!,
            );
        return _MessageBubble(
          message: message,
          isMine: isMine,
          isRead: isRead,
        );
      },
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: _onTextChanged,
                decoration: const InputDecoration(
                  hintText: 'Mesaj yaz...',
                ),
                minLines: 1,
                maxLines: 4,
                textInputAction:
                    TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool isRead;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMine
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).cardColor;
    final textColor = isMine
        ? Colors.white
        : null;

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.7,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content ?? '',
              style: TextStyle(color: textColor),
            ),
            if (isMine) ...[
              const SizedBox(height: 2),
              Icon(
                isRead
                    ? Icons.done_all
                    : Icons.done,
                size: 14,
                color: isRead
                    ? Colors.lightBlueAccent
                    : Colors.white70,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
