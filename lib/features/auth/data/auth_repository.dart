import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/preferences_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storage;
  final PreferencesService prefs;

  AuthRepository({
    required this.apiClient,
    required this.storage,
    required this.prefs,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    final accessToken = response['accessToken'] ?? response['token'];
    final refreshToken = response['refreshToken'] ?? accessToken;

    if (accessToken != null) {
      await storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    final user = UserModel.fromJson(response['user']);
    await prefs.saveCachedUser(user.toJson());
    return user;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.register,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    final accessToken = response['accessToken'] ?? response['token'];
    final refreshToken = response['refreshToken'] ?? accessToken;
    if (accessToken != null) {
      await storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    if (response['user'] != null) {
      final user = UserModel.fromJson(response['user']);
      await prefs.saveCachedUser(user.toJson());
    }
  }

  Future<UserModel> getProfile() async {
    final response = await apiClient.get(ApiConstants.profile);
    final user = UserModel.fromJson(response['user']);
    await prefs.saveCachedUser(user.toJson());
    return user;
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = await apiClient.put(
      ApiConstants.profile,
      data: {
        'name': name.trim(),
        'email': email.trim(),
      },
    );
    final user = UserModel.fromJson(response['user']);
    await prefs.saveCachedUser(user.toJson());
    return user;
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await apiClient.put(
      ApiConstants.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> deleteProfile() async {
    await apiClient.delete(ApiConstants.profile);
    await storage.clearAll();
    await prefs.clearCachedUser();
  }

  Future<void> logout() async {
    await storage.clearAll();
    await prefs.clearCachedUser();
  }

  UserModel? getCachedUser() {
    final map = prefs.getCachedUser();
    if (map != null) {
      return UserModel.fromJson(map);
    }
    return null;
  }

  Future<bool> hasValidToken() async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      return true;
    }
    final refreshToken = await storage.getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }
}
