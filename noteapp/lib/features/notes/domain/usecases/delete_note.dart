import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class DeleteNote {
  final NoteRepository noteRepository;
  DeleteNote({required this.noteRepository});

  Future<void> call(Note note) async {
    await noteRepository.deleteNote(note);
  }
}
