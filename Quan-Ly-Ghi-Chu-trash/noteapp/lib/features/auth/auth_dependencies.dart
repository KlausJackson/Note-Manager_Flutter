import 'package:get_it/get_it.dart';

// Data Layer
import 'data/datasources/auth_remote.dart';
import 'data/datasources/auth_local.dart';
import 'data/repositories/auth_repository_impl.dart';

// Domain Layer
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login.dart';
import 'domain/usecases/register.dart';
import 'domain/usecases/logout.dart';
import 'domain/usecases/delete_user.dart';
import 'domain/usecases/get_saved_users.dart';
import 'domain/usecases/delete_saved_user.dart';
import 'domain/usecases/get_current_user.dart';

// Presentation Layer
import 'presentation/provider/auth_provider.dart';

void initAuthDependencies(GetIt sl) {
  // Provider
  sl.registerFactory(
    () => AuthProvider(
      loginUsecase: sl(),
      registerUsecase: sl(),
      logoutUsecase: sl(),
      deleteUserUsecase: sl(),
      getSavedUsersUsecase: sl(),
      deleteSavedUserUsecase: sl(),
      getCurrentUserUsecase: sl(),
      noteProvider: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => Login(authRepository: sl()));
  sl.registerLazySingleton(() => Register(authRepository: sl()));
  sl.registerLazySingleton(() => Logout(authRepository: sl()));
  sl.registerLazySingleton(() => DeleteUser(authRepository: sl()));
  sl.registerLazySingleton(() => GetSavedUsers(authRepository: sl()));
  sl.registerLazySingleton(() => DeleteSavedUser(authRepository: sl()));
  sl.registerLazySingleton(() => GetCurrentUser(authRepository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemote: sl(), authLocal: sl()),
  );

  // Data Sources
  sl.registerLazySingleton(() => AuthRemote(apiClient: sl()));
  sl.registerLazySingleton(
    () => AuthLocal(secureStorage: sl(), profilesBox: sl()),
  );
}
