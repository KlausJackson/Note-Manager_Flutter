import 'package:noteapp/features/auth/domain/repositories/auth_repository.dart';

class DeleteSavedUser {
  final AuthRepository authRepository;
  DeleteSavedUser({required this.authRepository});

  Future<void> call({required String username}) async {
    await authRepository.deleteSavedUser(username: username);
  }
}
