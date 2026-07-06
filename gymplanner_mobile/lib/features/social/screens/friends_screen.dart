import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/features/social/providers/social_provider.dart';
import 'package:gymplanner_mobile/features/social/screens/requests_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() =>
      _FriendsScreenState();
}

class _FriendsScreenState
    extends ConsumerState<FriendsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(socialProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        ref
            .read(socialProvider.notifier)
            .searchUsers(value);
      },
    );
  }

  void _openSearchSheet() {
    _searchController.clear();
    ref.read(socialProvider.notifier).clearSearch();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SearchFriendsSheet(
        controller: _searchController,
        onChanged: _onSearchChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaşlarım'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.mail_outline,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const RequestsScreen(),
                    ),
                  );
                },
              ),
              if (state.pendingRequests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                    child: Text(
                      state.pendingRequests.length
                          .toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(socialProvider.notifier)
            .loadFriends(),
        child: _buildBody(state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSearchSheet,
        child: const Icon(
          Icons.person_add_alt_1,
        ),
      ),
    );
  }

  Widget _buildBody(SocialState state) {
    if (state.isLoadingFriends &&
        state.friends.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null &&
        state.friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.friends.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text('Henüz arkadaşın yok'),
          ),
        ],
      );
    }

    return ListView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.friends.length,
      itemBuilder: (context, index) {
        final friend = state.friends[index];
        return Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                friend.username.isNotEmpty
                    ? friend.username[0]
                          .toUpperCase()
                    : '?',
              ),
            ),
            title: Text(friend.username),
          ),
        );
      },
    );
  }
}

class _SearchFriendsSheet
    extends ConsumerWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchFriendsSheet({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(socialProvider);
    final bottomInset = MediaQuery.of(
      context,
    ).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomInset + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Text(
              'Arkadaş Ekle',
              style: Theme.of(
                context,
              ).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Kullanıcı adı ara',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: _buildResults(
                context,
                ref,
                state,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    WidgetRef ref,
    SocialState state,
  ) {
    if (state.isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Aramak için en az 2 karakter yaz',
        ),
      );
    }

    return ListView.builder(
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final user = state.searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              user.username.isNotEmpty
                  ? user.username[0].toUpperCase()
                  : '?',
            ),
          ),
          title: Text(user.username),
          subtitle: Text(
            '${user.name} ${user.surname}',
          ),
          trailing: TextButton(
            onPressed: () async {
              final success = await ref
                  .read(socialProvider.notifier)
                  .sendFriendRequest(user.id);

              if (!context.mounted) return;

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'İstek gönderildi!'
                        : ref
                                  .read(
                                    socialProvider,
                                  )
                                  .errorMessage ??
                              'İstek gönderilemedi.',
                  ),
                ),
              );
            },
            child: const Text('Ekle'),
          ),
        );
      },
    );
  }
}