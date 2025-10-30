import 'package:noteapp/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<Map<String, dynamic>> getNotes(
    String? query,
    String sortBy,
    int sortOrder,
    int page,
    int pageSize,
  );
  Future<List<Note>> getTrashedNotes();
  Future<Note> createNote(Note note);
  Future<Note> updateNote(Note note);
  Future<void> syncNotes();
  // send note to server, server sends back the note
  // (with changes like updatedAt timestamp or trimmed fields)
  // save that note from server to local db
  // because server is source of truth
  Future<bool> deleteNote(Note note);
  Future<bool> restoreNote(Note note);
  Future<bool> permanentlyDeleteNote(Note note);
}
