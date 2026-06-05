import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/features/auth/data/auth_repository.dart';

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

  AuthNotifier(this._repository)
    : super(const AuthState());

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
      state = state.copyWith(
        status: AuthStatus.success,
        user: data['user'],
      );
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
      state = state.copyWith(
        status: AuthStatus.success,
        user: data['user'],
      );
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

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authProvider =
    StateNotifierProvider<
      AuthNotifier,
      AuthState
    >(
      (ref) => AuthNotifier(
        ref.watch(authRepositoryProvider),
      ),
    );
