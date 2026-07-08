import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/network/socket_service.dart';
import 'package:gymplanner_mobile/core/network/token_storage.dart';
import 'package:gymplanner_mobile/features/auth/data/auth_repository.dart';
import 'package:gymplanner_mobile/features/calorie/providers/calorie_provider.dart';
import 'package:gymplanner_mobile/features/home/providers/home_provider.dart';
import 'package:gymplanner_mobile/features/messaging/providers/message_provider.dart';
import 'package:gymplanner_mobile/features/profile/providers/profile_provider.dart';
import 'package:gymplanner_mobile/features/workout/providers/workout_provider.dart';

// Repository provider
final authRepositoryProvider =
    Provider<AuthRepository>(
      (ref) => AuthRepository(),
    );

// Auth state
enum AuthStatus {
  initial,
  loading,
  success,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage:
          errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier
    extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref; // YENİ

  AuthNotifier(
    this._repository,
    this._ref,
  ) // YENİ: _ref parametresi
  : super(const AuthState());

  void _connectSocket(
    Map<String, dynamic>? user,
  ) {
    final id = user?['id'];
    if (id != null) {
      SocketService.instance.connect(
        id.toString(),
      );
    }
  }

  // YENİ
  void _invalidateUserScopedProviders() {
    _ref.invalidate(profileProvider);
    _ref.invalidate(workoutProvider);
    _ref.invalidate(homeProvider);
    _ref.invalidate(conversationListProvider);
    _ref.invalidate(calorieProvider);
  }

  Future<bool> login({
    required String loginInput,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
    );
    try {
      final data = await _repository.login(
        loginInput: loginInput,
        password: password,
      );
      _invalidateUserScopedProviders(); // YENİ: state'i user set edilmeden ÖNCE temizle
      state = state.copyWith(
        status: AuthStatus.success,
        user: data['user'],
      );
      _connectSocket(data['user']);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String name,
    required String surname,
    required String gender,
    String? phone,
    String? birthdate,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
    );
    try {
      final data = await _repository.register(
        username: username,
        email: email,
        password: password,
        name: name,
        surname: surname,
        gender: gender,
        phone: phone,
        birthdate: birthdate,
      );
      _invalidateUserScopedProviders(); // YENİ
      state = state.copyWith(
        status: AuthStatus.success,
        user: data['user'],
      );
      _connectSocket(data['user']);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    final hasToken =
        await TokenStorage.isLoggedIn();
    if (!hasToken) {
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.loading,
    );
    try {
      final user = await _repository.getProfile();
      state = state.copyWith(
        status: AuthStatus.success,
        user: user,
      );
      _connectSocket(user);
      return true;
    } catch (e) {
      await _repository.logout();
      state = const AuthState();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    SocketService.instance.disconnect();
    state = const AuthState();
    _invalidateUserScopedProviders(); // YENİ
  }
}

final authProvider =
    StateNotifierProvider<
      AuthNotifier,
      AuthState
    >(
      (ref) => AuthNotifier(
        ref.watch(authRepositoryProvider),
        ref,
      ), // YENİ: ref eklendi
    );
