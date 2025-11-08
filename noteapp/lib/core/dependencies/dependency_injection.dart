import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:noteapp/core/network/api_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:noteapp/core/network/network_info.dart';

// Models
import 'package:noteapp/features/auth/data/models/user_model.dart';
import 'package:noteapp/features/notes/data/models/block_model.dart';
import 'package:noteapp/features/notes/data/models/note_model.dart';

import 'package:noteapp/features/auth/auth_dependencies.dart';
import 'package:noteapp/features/notes/note_dependencies.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- CORE DEPENDENCIES ---
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => NetworkInfo(sl()));
  sl.registerLazySingleton(() => Connectivity());

  // --- HIVE ---
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(BlockModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());

  final profilesBox = await Hive.openBox<UserModel>('profiles');
  sl.registerLazySingleton<Box<UserModel>>(() => profilesBox);

  // --- FEATURE DEPENDENCIES ---
  initAuthDependencies(sl);
  initNoteDependencies(sl);
}
