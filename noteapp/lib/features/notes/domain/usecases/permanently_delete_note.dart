import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class PermanentlyDeleteNote {
  final NoteRepository noteRepository;
  PermanentlyDeleteNote({required this.noteRepository});

  Future<bool> call(Note note) async {
    return await noteRepository.permanentlyDeleteNote(note);
  }
}