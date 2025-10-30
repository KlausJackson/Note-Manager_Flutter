import 'package:hive_flutter/hive_flutter.dart';
import 'package:noteapp/features/notes/data/models/note_model.dart';

class NoteLocal {
  Future<Box<NoteModel>> _getNotesBox(String userKey) {
    return Hive.openBox<NoteModel>('notes_$userKey');
  }

  Future<List<NoteModel>> getNotes(String userKey) async {
    final box = await _getNotesBox(userKey);
    return box.values.toList();
  }

  // put method to save / update (upsert)
  Future<void> upsertNote(String userKey, NoteModel note) async {
    final box = await _getNotesBox(userKey);
    await box.put(note.uuid, note);
  }

  Future<void> upsertNotes(String userKey, List<NoteModel> notes) async {
    final box = await _getNotesBox(userKey);
    final Map<String?, NoteModel> notesMap = {
      for (var note in notes) note.uuid: note,
    };
    await box.putAll(notesMap);
  }

  Future<void> deleteNote(String userKey, String uuid) async {
    final box = await _getNotesBox(userKey);
    await box.delete(uuid);
  }
}
