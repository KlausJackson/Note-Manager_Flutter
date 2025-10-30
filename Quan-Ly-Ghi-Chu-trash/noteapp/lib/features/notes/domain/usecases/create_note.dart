import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class CreateNote {
  final NoteRepository noteRepository;
  CreateNote({required this.noteRepository});

  Future<Note> call(Note note) async {
    return await noteRepository.createNote(note);
  }
}
