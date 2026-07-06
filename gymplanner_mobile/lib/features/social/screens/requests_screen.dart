import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/features/social/providers/social_provider.dart';

class RequestsScreen
    extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() =>
      _RequestsScreenState();
}

class _RequestsScreenState
    extends ConsumerState<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(socialProvider.notifier)
          .loadPendingRequests();
    });
  }

  Future<void> _respond(
    int friendshipId,
    String status,
  ) async {
    await ref
        .read(socialProvider.notifier)
        .respondToRequest(
          friendshipId: friendshipId,
          status: status,
        );

    if (!mounted) return;

    final error = ref
        .read(socialProvider)
        .errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bekleyen İstekler'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(socialProvider.notifier)
            .loadPendingRequests(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(SocialState state) {
    if (state.isLoadingRequests &&
        state.pendingRequests.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.pendingRequests.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text('Bekleyen istek yok'),
          ),
        ],
      );
    }

    return ListView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.pendingRequests.length,
      itemBuilder: (context, index) {
        final request =
            state.pendingRequests[index];
        final isProcessing = state
            .processingRequestIds
            .contains(request.friendshipId);

        return Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                request
                        .requesterUsername
                        .isNotEmpty
                    ? request.requesterUsername[0]
                          .toUpperCase()
                    : '?',
              ),
            ),
            title: Text(
              request.requesterUsername,
            ),
            subtitle: const Text(
              'Sana arkadaşlık isteği gönderdi',
            ),
            trailing: isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                  )
                : Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons
                              .check_circle_outline,
                          color: Colors.green,
                        ),
                        onPressed: () => _respond(
                          request.friendshipId,
                          'accepted',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _respond(
                          request.friendshipId,
                          'rejected',
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
