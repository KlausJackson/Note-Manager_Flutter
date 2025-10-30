import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class RestoreNote {
  final NoteRepository noteRepository;
  RestoreNote({required this.noteRepository});

  Future<bool> call(Note note) async {
    return await noteRepository.restoreNote(note);
  }
}