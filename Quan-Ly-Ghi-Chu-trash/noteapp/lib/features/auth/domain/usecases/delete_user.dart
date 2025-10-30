import 'package:noteapp/features/auth/domain/repositories/auth_repository.dart';

class DeleteUser {
  final AuthRepository authRepository;
  DeleteUser({required this.authRepository});

  Future<void> call({required String username, required String password}) async {
    await authRepository.deleteUser(username: username, password: password);
  }
}
