import 'package:ankiblog_mobile/data/models/user.dart';
import 'package:ankiblog_mobile/data/repositories/auth_repository.dart';
import 'package:ankiblog_mobile/data/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final User? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository, this._userRepository)
    : super(const AuthState());

  static const sessionExpiredMessage = '登录已过期，请重新登录';

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<void> init() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepository.getStoredUser();
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
        // Refresh user profile in background
        refreshProfile();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _authRepository.login(
        username: username,
        password: password,
      );
      state = state.copyWith(user: response.user, isLoading: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: _extractMessage(e));
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
    required String verificationCode,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepository.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
        verificationCode: verificationCode,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: _extractMessage(e));
      return false;
    }
  }

  Future<void> sendRegisterCode(String email) async {
    await _authRepository.sendRegisterCode(email);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState();
  }

  bool handleSessionExpired({String message = sessionExpiredMessage}) {
    if (!state.isAuthenticated && state.error == message) {
      return false;
    }

    state = AuthState(error: message);
    return true;
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _userRepository.getProfile();
      state = state.copyWith(user: user);
    } catch (_) {
      // Ignore profile refresh errors
    }
  }

  String _extractMessage(Exception e) {
    if (e is FormatException) return e.message;
    return e.toString();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
  notifier.init();
  return notifier;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
