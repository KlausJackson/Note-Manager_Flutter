import 'package:get_it/get_it.dart';

// Data Layer
import 'data/datasources/note_remote.dart';
import 'data/datasources/note_local.dart';
import 'data/repositories/note_repository_impl.dart';

// Domain Layer
import 'domain/repositories/note_repository.dart';
import 'domain/usecases/get_notes.dart';
import 'domain/usecases/create_note.dart';
import 'domain/usecases/update_note.dart';
import 'domain/usecases/delete_note.dart';
import 'domain/usecases/restore_note.dart';
import 'domain/usecases/permanently_delete_note.dart';
import 'domain/usecases/sync_notes.dart';
import 'domain/usecases/get_trashed_notes.dart';

// Presentation Layer
import 'presentation/provider/note_provider.dart';

void initNoteDependencies(GetIt sl) {
  // Provider
  sl.registerFactory(
    () => NoteProvider(
      getNotesUsecase: sl(),
      createNoteUsecase: sl(),
      updateNoteUsecase: sl(),
      deleteNoteUsecase: sl(),
      restoreNoteUsecase: sl(),
      permanentlyDeleteNoteUsecase: sl(),
      syncNotesUsecase: sl(),
      getTrashedNotesUsecase: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => GetNotes(noteRepository: sl()));
  sl.registerLazySingleton(() => CreateNote(noteRepository: sl()));
  sl.registerLazySingleton(() => UpdateNote(noteRepository: sl()));
  sl.registerLazySingleton(() => SyncNotes(noteRepository: sl()));
  sl.registerLazySingleton(() => DeleteNote(noteRepository: sl()));
  sl.registerLazySingleton(() => RestoreNote(noteRepository: sl()));
  sl.registerLazySingleton(() => PermanentlyDeleteNote(noteRepository: sl()));
  sl.registerLazySingleton(() => GetTrashedNotes(noteRepository: sl()));

  // Repository
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      noteRemote: sl(),
      noteLocal: sl(),
      authLocal: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton(() => NoteRemote(apiClient: sl()));
  sl.registerLazySingleton(() => NoteLocal());
}
