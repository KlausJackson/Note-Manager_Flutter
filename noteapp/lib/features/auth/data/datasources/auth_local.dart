import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:noteapp/features/auth/data/models/user_model.dart';

class AuthLocal {
  final FlutterSecureStorage secureStorage;
  final Box<UserModel> profilesBox;
  AuthLocal({required this.secureStorage, required this.profilesBox});

  // ---- Token Management ----
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'authToken', value: token);
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'authToken');
  }

  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'authToken');
  }

  // ---- User Management ----
  Future<void> saveUser(UserModel profile) async {
    await profilesBox.put(profile.username, profile);
  }

  Future<List<UserModel>> getUsers() async {
    return profilesBox.values.toList();
  }

  Future<void> deleteSavedUser(String username) async {
    await profilesBox.delete(username);
  }

  Future<String?> getCurrentUser() async {
    return await secureStorage.read(key: 'currentUser');
  }

  Future<void> saveCurrentUser(String username) async {
    await secureStorage.write(key: 'currentUser', value: username);
  }

  Future<void> deleteCurrentUser() async {
    await secureStorage.delete(key: 'currentUser');
  }

  // --- Last Synced ---
  Future<void> updateLastSynced(String username, String timestamp) async {
    final user = profilesBox.get(username);
    if (user != null) {
      final updatedUser = UserModel(
        username: user.username,
        lastSynced: timestamp,
      );
      await profilesBox.put(username, updatedUser);
    }
  }

  Future<String?> getLastSynced(String username) async {
    final user = profilesBox.get(username);
    return user?.lastSynced;
  }
}
