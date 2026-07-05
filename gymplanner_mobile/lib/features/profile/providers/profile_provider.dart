import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/user_model.dart';
import 'package:gymplanner_mobile/features/profile/data/profile_repository.dart';

final profileRepositoryProvider =
    Provider<ProfileRepository>(
      (ref) => ProfileRepository(),
    );

class ProfileState {
  final UserModel? user;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  ProfileState({
    this.user,
    required this.isLoading,
    required this.isSaving,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class ProfileNotifier
    extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository)
    : super(
        ProfileState(
          isLoading: false,
          isSaving: false,
        ),
      );

  Future<void> loadProfile() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    try {
      final user = await _repository.getProfile();
      state = state.copyWith(
        user: user,
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

  Future<bool> updateProfile({
    String? username,
    String? name,
    String? surname,
    String? phone,
    String? birthdate,
    String? gender,
    String? locationPreference,
    String? email,
  }) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final updatedUser = await _repository
          .updateProfile(
            username: username,
            name: name,
            surname: surname,
            phone: phone,
            birthdate: birthdate,
            gender: gender,
            locationPreference:
                locationPreference,
            email: email,
          );
      state = state.copyWith(
        user: updatedUser,
        isSaving: false,
        successMessage: 'Profil güncellendi.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
      (ref) => ProfileNotifier(
        ref.watch(profileRepositoryProvider),
      ),
    );