import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class SyncNotes {
  final NoteRepository noteRepository;
  SyncNotes({required this.noteRepository});

  Future<bool> call() async {
    return await noteRepository.syncNotes();
  }
}
