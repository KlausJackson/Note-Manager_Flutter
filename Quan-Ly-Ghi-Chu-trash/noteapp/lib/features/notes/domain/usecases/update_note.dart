import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class UpdateNote {
  final NoteRepository noteRepository;
  UpdateNote({required this.noteRepository});

  Future<Note> call(Note note) async {
    return await noteRepository.updateNote(note);
  }
}
