import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/friend_model.dart';
import 'package:gymplanner_mobile/core/models/friend_request_model.dart';
import 'package:gymplanner_mobile/core/models/user_search_result_model.dart';
import 'package:gymplanner_mobile/features/social/data/social_repository.dart';

final socialRepositoryProvider =
    Provider<SocialRepository>(
      (ref) => SocialRepository(),
    );

class SocialState {
  final List<FriendModel> friends;
  final List<FriendRequestModel> pendingRequests;
  final List<UserSearchResultModel> searchResults;
  final Set<int> processingRequestIds;
  final bool isLoadingFriends;
  final bool isLoadingRequests;
  final bool isSearching;
  final String? errorMessage;

  SocialState({
    required this.friends,
    required this.pendingRequests,
    required this.searchResults,
    required this.processingRequestIds,
    required this.isLoadingFriends,
    required this.isLoadingRequests,
    required this.isSearching,
    this.errorMessage,
  });

  SocialState copyWith({
    List<FriendModel>? friends,
    List<FriendRequestModel>? pendingRequests,
    List<UserSearchResultModel>? searchResults,
    Set<int>? processingRequestIds,
    bool? isLoadingFriends,
    bool? isLoadingRequests,
    bool? isSearching,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SocialState(
      friends: friends ?? this.friends,
      pendingRequests:
          pendingRequests ?? this.pendingRequests,
      searchResults:
          searchResults ?? this.searchResults,
      processingRequestIds:
          processingRequestIds ??
          this.processingRequestIds,
      isLoadingFriends:
          isLoadingFriends ??
          this.isLoadingFriends,
      isLoadingRequests:
          isLoadingRequests ??
          this.isLoadingRequests,
      isSearching:
          isSearching ?? this.isSearching,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class SocialNotifier
    extends StateNotifier<SocialState> {
  final SocialRepository _repository;

  SocialNotifier(this._repository)
    : super(
        SocialState(
          friends: const [],
          pendingRequests: const [],
          searchResults: const [],
          processingRequestIds: const {},
          isLoadingFriends: false,
          isLoadingRequests: false,
          isSearching: false,
        ),
      );

  Future<void> loadFriends() async {
    state = state.copyWith(
      isLoadingFriends: true,
      clearError: true,
    );
    try {
      final friends = await _repository
          .getMyFriends();
      state = state.copyWith(
        friends: friends,
        isLoadingFriends: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingFriends: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<void> loadPendingRequests() async {
    state = state.copyWith(
      isLoadingRequests: true,
      clearError: true,
    );
    try {
      final requests = await _repository
          .getPendingRequests();
      state = state.copyWith(
        pendingRequests: requests,
        isLoadingRequests: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingRequests: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadFriends(),
      loadPendingRequests(),
    ]);
  }

  Future<bool> sendFriendRequest(
    int receiverId,
  ) async {
    try {
      await _repository.sendFriendRequest(
        receiverId,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }

  Future<void> respondToRequest({
    required int friendshipId,
    required String status,
  }) async {
    final processing = Set<int>.from(
      state.processingRequestIds,
    )..add(friendshipId);
    state = state.copyWith(
      processingRequestIds: processing,
      clearError: true,
    );

    try {
      await _repository.respondToRequest(
        friendshipId: friendshipId,
        status: status,
      );

      final updatedRequests = state
          .pendingRequests
          .where(
            (r) => r.friendshipId != friendshipId,
          )
          .toList();
      final updatedProcessing = Set<int>.from(
        state.processingRequestIds,
      )..remove(friendshipId);

      state = state.copyWith(
        pendingRequests: updatedRequests,
        processingRequestIds: updatedProcessing,
      );

      if (status == 'accepted') {
        await loadFriends();
      }
    } catch (e) {
      final updatedProcessing = Set<int>.from(
        state.processingRequestIds,
      )..remove(friendshipId);
      state = state.copyWith(
        processingRequestIds: updatedProcessing,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().length < 2) {
      state = state.copyWith(
        searchResults: const [],
      );
      return;
    }

    state = state.copyWith(
      isSearching: true,
      clearError: true,
    );
    try {
      final results = await _repository
          .searchUsers(query.trim());
      state = state.copyWith(
        searchResults: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(
      searchResults: const [],
    );
  }
}

final socialProvider =
    StateNotifierProvider<
      SocialNotifier,
      SocialState
    >(
      (ref) => SocialNotifier(
        ref.watch(socialRepositoryProvider),
      ),
    );
