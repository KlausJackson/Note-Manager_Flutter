import 'package:noteapp/features/auth/domain/entities/user.dart';
import 'package:noteapp/features/auth/domain/repositories/auth_repository.dart';

class GetSavedUsers {
  final AuthRepository authRepository;
  GetSavedUsers({required this.authRepository});

  Future<List<User>> call() async {
    return await authRepository.getSavedUsers();
  }
}