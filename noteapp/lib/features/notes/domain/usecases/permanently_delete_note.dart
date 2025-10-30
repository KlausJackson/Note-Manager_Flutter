import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class PermanentlyDeleteNote {
  final NoteRepository noteRepository;
  PermanentlyDeleteNote({required this.noteRepository});

  Future<void> call(Note note) async {
    await noteRepository.permanentlyDeleteNote(note.uuid);
  }
}