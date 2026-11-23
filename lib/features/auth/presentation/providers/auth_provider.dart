import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanagement_app/core/network/api_client.dart';
import 'package:taskmanagement_app/core/storage/preferences_service.dart';
import 'package:taskmanagement_app/core/storage/secure_storage_service.dart';
import 'package:taskmanagement_app/features/auth/data/auth_repository.dart';
import 'package:taskmanagement_app/features/auth/data/models/user_model.dart';

// Core Service Providers
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('preferencesService must be initialized in main');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final client = ApiClient(storage: storage);
  return client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  final prefs = ref.watch(preferencesServiceProvider);
  return AuthRepository(apiClient: apiClient, storage: storage, prefs: prefs);
});

// Auth State Definition
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final ApiClient _apiClient;

  AuthNotifier(this._repository, this._apiClient) : super(AuthState.initial()) {
    _apiClient.onUnauthorized = () {
      forceLogout();
    };
  }

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final hasToken = await _repository.hasValidToken();
      if (!hasToken) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // Check for cached user so the app enters dashboard immediately
      final cachedUser = _repository.getCachedUser();
      if (cachedUser != null) {
        state = AuthState(status: AuthStatus.authenticated, user: cachedUser);
      }

      // Validate/refresh session with backend silently
      try {
        final user = await _repository.getProfile();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        // If profile fetch encounters network delay or timeout, DO NOT log the user out!
        // As long as valid tokens exist, preserve authenticated state
        if (cachedUser == null) {
          final stillHasToken = await _repository.hasValidToken();
          if (stillHasToken) {
            state = AuthState(
              status: AuthStatus.authenticated,
              user: UserModel(id: '', name: 'User', email: ''),
            );
          } else {
            state = const AuthState(status: AuthStatus.unauthenticated);
          }
        }
      }
    } catch (_) {
      final stillHasToken = await _repository.hasValidToken();
      if (!stillHasToken) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.register(name: name, email: email, password: password);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProfile(String name, String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final updatedUser = await _repository.updateProfile(name: name, email: email);
      state = AuthState(status: AuthStatus.authenticated, user: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _repository.deleteProfile();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> forceLogout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final client = ref.watch(apiClientProvider);
  return AuthNotifier(repo, client);
});
