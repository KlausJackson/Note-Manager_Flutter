import 'package:noteapp/features/auth/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository authRepository;
  Logout({required this.authRepository});

  Future<void> call() async {
    await authRepository.logout();
  }
}
