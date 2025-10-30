import 'package:noteapp/features/auth/domain/repositories/auth_repository.dart';

class Login {
  final AuthRepository authRepository;
  Login({required this.authRepository});

  Future<void> call({
    required String username,
    required String password,
  }) async {
    await authRepository.login(username: username, password: password);
  }
}
