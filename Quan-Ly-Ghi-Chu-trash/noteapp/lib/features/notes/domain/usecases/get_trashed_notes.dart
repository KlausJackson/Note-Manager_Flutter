import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class GetTrashedNotes {
  final NoteRepository noteRepository;
  GetTrashedNotes({required this.noteRepository});

  Future<List<Note>> call() async {
    return await noteRepository.getTrashedNotes();
  }
}