import 'package:noteapp/features/auth/domain/repositories/auth_repository.dart';

class Register {
  final AuthRepository authRepository;
  Register({required this.authRepository});

  Future<void> call({
    required String username,
    required String password,
  }) async {
    await authRepository.register(username: username, password: password);
  }
}
