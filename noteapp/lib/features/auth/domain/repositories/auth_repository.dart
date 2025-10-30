import 'package:noteapp/features/auth/domain/entities/user.dart';
// defines *what* you can do with authentication data, but not *how*.

abstract class AuthRepository {
  Future<void> login({required String username, required String password});
  Future<void> register({required String username, required String password});
  Future<void> logout();
  Future<void> deleteUser({required String username, required String password});
  Future<void> deleteSavedUser({required String username});
  Future<List<User>> getSavedUsers();
  Future<String?> getCurrentUser();
}
