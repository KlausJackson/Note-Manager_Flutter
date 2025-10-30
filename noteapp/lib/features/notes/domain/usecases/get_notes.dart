import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class GetNotes {
  final NoteRepository noteRepository;
  GetNotes({required this.noteRepository});

  Future<Map<String, dynamic>> call(String? query, String sortBy, int sortOrder, int page, int pageSize) async {
    return await noteRepository.getNotes(query, sortBy, sortOrder, page, pageSize);
  }
}
