import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class RestoreNote {
  final NoteRepository noteRepository;
  RestoreNote({required this.noteRepository});

  Future<void> call(Note note) async {
    await noteRepository.restoreNote(note.uuid);
  }
}