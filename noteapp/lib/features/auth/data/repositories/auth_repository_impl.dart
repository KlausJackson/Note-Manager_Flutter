import 'package:noteapp/features/auth/domain/entities/user.dart';
import 'package:noteapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:noteapp/features/auth/data/datasources/auth_remote.dart';
import 'package:noteapp/features/auth/data/datasources/auth_local.dart';
import 'package:noteapp/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemote authRemote;
  final AuthLocal authLocal;
  AuthRepositoryImpl({required this.authRemote, required this.authLocal});

  Future<void> _authenticate({
    required String action,
    required String username,
    required String password,
  }) async {
    final Map<String, dynamic> response = action == 'login'
        ? await authRemote.login(username: username, password: password)
        : await authRemote.register(username: username, password: password);

    final String token = response['data'];
    final Map<String, dynamic> userJson = {'username': username};
    final userModel = UserModel.fromJson(userJson);

    await authLocal.saveToken(token);
    await authLocal.saveUser(userModel);
    await authLocal.saveCurrentUser(username);
  }

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _authenticate(
      action: 'login',
      username: username,
      password: password,
    );
  }

  @override
  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _authenticate(
      action: 'register',
      username: username,
      password: password,
    );
  }

  @override
  Future<void> deleteUser({
    required String username,
    required String password,
  }) async {
    await authRemote.deleteUser(password: password);
    await logout();
    await authLocal.deleteSavedUser(username);
  }

  @override
  Future<void> logout() async {
    await authLocal.deleteToken();
    await authLocal.deleteCurrentUser();
  }

  @override
  Future<List<User>> getSavedUsers() async {
    return await authLocal.getUsers();
  }

  @override
  Future<void> deleteSavedUser({required String username}) async {
    await authLocal.deleteSavedUser(username);
  }

  @override
  Future<String?> getCurrentUser() async {
    return await authLocal.getCurrentUser();
  }
}
