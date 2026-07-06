import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/features/auth/providers/auth_provider.dart';
import 'package:gymplanner_mobile/features/messaging/providers/message_provider.dart';
import 'package:gymplanner_mobile/features/messaging/screens/chat_screen.dart';

class ConversationListScreen
    extends ConsumerWidget {
  const ConversationListScreen({super.key});

  int _resolveUserId(Map<String, dynamic>? user) {
    final id = user?['id'];
    if (id is int) return id;
    if (id is String)
      return int.tryParse(id) ?? -1;
    return -1;
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(
      conversationListProvider,
    );
    final currentUserId = _resolveUserId(
      ref.watch(authProvider).user,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sohbetlerim'),
      ),
      body: _buildBody(
        context,
        ref,
        state,
        currentUserId,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ConversationListState state,
    int currentUserId,
  ) {
    if (state.isLoading &&
        state.conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null &&
        state.conversations.isEmpty) {
      return Center(
        child: Text(state.errorMessage!),
      );
    }

    if (state.conversations.isEmpty) {
      return const Center(
        child: Text('Henüz bir sohbetin yok'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(conversationListProvider.notifier)
          .loadConversations(),
      child: ListView.separated(
        itemCount: state.conversations.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation =
              state.conversations[index];
          final displayName = conversation
              .displayName(currentUserId);
          final otherUser = conversation
              .participants
              .firstWhere(
                (p) => p.id != currentUserId,
                orElse: () => conversation
                    .participants
                    .first,
              );
          final lastMessage =
              conversation.lastMessage;
          final subtitle = lastMessage == null
              ? 'Henüz mesaj yok'
              : (lastMessage.type == 'image'
                    ? '📷 Fotoğraf'
                    : (lastMessage.content ??
                          ''));

          return ListTile(
            leading: CircleAvatar(
              child: Text(
                displayName.isNotEmpty
                    ? displayName[0].toUpperCase()
                    : '?',
              ),
            ),
            title: Text(
              displayName,
              style: TextStyle(
                fontWeight: conversation.isUnread
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: conversation.isUnread
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
            trailing: conversation.isUnread
                ? const CircleAvatar(
                    radius: 5,
                    backgroundColor:
                        Colors.orange,
                  )
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    conversationId:
                        conversation.id,
                    otherUserId: otherUser.id,
                    otherUserName: displayName,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
