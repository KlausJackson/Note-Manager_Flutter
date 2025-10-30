import 'package:flutter/material.dart';

// entity
import 'package:noteapp/features/notes/domain/entities/note.dart';

// usecases
import 'package:noteapp/features/notes/domain/usecases/get_notes.dart';
import 'package:noteapp/features/notes/domain/usecases/create_note.dart';
import 'package:noteapp/features/notes/domain/usecases/update_note.dart';
import 'package:noteapp/features/notes/domain/usecases/delete_note.dart';
import 'package:noteapp/features/notes/domain/usecases/restore_note.dart';
import 'package:noteapp/features/notes/domain/usecases/permanently_delete_note.dart';
import 'package:noteapp/features/notes/domain/usecases/sync_notes.dart';
import 'package:noteapp/features/notes/domain/usecases/get_trashed_notes.dart';

enum NoteStatus { initial, loading, success, error }

class NoteProvider with ChangeNotifier {
  // --- Usecase Dependencies ---
  final GetNotes getNotesUsecase;
  final CreateNote createNoteUsecase;
  final UpdateNote updateNoteUsecase;
  final DeleteNote deleteNoteUsecase;
  final RestoreNote restoreNoteUsecase;
  final PermanentlyDeleteNote permanentlyDeleteNoteUsecase;
  final SyncNotes syncNotesUsecase;
  final GetTrashedNotes getTrashedNotesUsecase;

  NoteProvider({
    required this.getNotesUsecase,
    required this.createNoteUsecase,
    required this.updateNoteUsecase,
    required this.deleteNoteUsecase,
    required this.restoreNoteUsecase,
    required this.permanentlyDeleteNoteUsecase,
    required this.syncNotesUsecase,
    required this.getTrashedNotesUsecase,
  });

  // --- State Properties ---
  NoteStatus _status = NoteStatus.initial;
  String _message = '';
  List<Note> _notes = [];
  List<Note> _trashedNotes = [];
  int _totalNotes = 0;

  // --- Getters ---
  NoteStatus get status => _status;
  String get message => _message;
  List<Note> get notes => _notes;
  List<Note> get trashedNotes => _trashedNotes;
  int get totalNotes => _totalNotes;
  String? get popMessage {
    if (_message.isEmpty) return null;
    final msg = _message;
    _message = '';
    return msg;
  }

  // --- Public Methods for the UI to Call ---
  Future<void> getNotes(
    String? query,
    String sortBy,
    int sortOrder,
    int page,
    int pageSize,
  ) async {
    _status = NoteStatus.loading;
    notifyListeners();

    try {
      Map<String, dynamic> result = await getNotesUsecase(
        query,
        sortBy,
        sortOrder,
        page,
        pageSize,
      );

      _notes = (result['notes'] as List).cast<Note>();
      _totalNotes = result['total'];
      _status = NoteStatus.success;
    } catch (e) {
      _status = NoteStatus.error;
      _message = e.toString();
    }
    notifyListeners();
  }

  Future<void> createNote(Note note) async {
    try {
      final createdNote = await createNoteUsecase(note);
      _notes.insert(0, createdNote); // update UI
      _status = NoteStatus.success;
      _totalNotes++;
      notifyListeners();
    } catch (e) {
      _status = NoteStatus.error;
      _message = 'Tạo ghi chú thất bại: $e';
      notifyListeners();
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updatedNote = await updateNoteUsecase(note);
      final index = _notes.indexWhere((n) => n.uuid == updatedNote.uuid);
      if (index != -1) {
        _notes[index] = updatedNote; // update UI
        notifyListeners();
      }
      _status = NoteStatus.success;
    } catch (e) {
      _status = NoteStatus.error;
      _message = 'Cập nhật ghi chú thất bại: $e';
      notifyListeners();
    }
  }

  void clearNotes() {
    _notes = [];
    notifyListeners();
  }

  Future<void> performSync() async {
    _status = NoteStatus.loading;
    notifyListeners();

    try {
      await syncNotesUsecase();
      await getNotes('', 'updatedAt', 1, 1, 20); // refresh notes
      _status = NoteStatus.success;
    } catch (e) {
      _status = NoteStatus.error;
      _message = 'Sync failed: $e';
    }
    notifyListeners();
  }

  Future<void> getTrashedNotes() async {
    _status = NoteStatus.loading;
    notifyListeners();

    try {
      _trashedNotes = await getTrashedNotesUsecase();
      _status = NoteStatus.success;
    } catch (e) {
      _status = NoteStatus.error;
      _message = 'Không thể lấy danh sách thùng rác ghi chú: $e';
    }
    notifyListeners();
  }

  Future<void> deleteNote(String uuid) async {
    try {
      final note = _notes.firstWhere((n) => n.uuid == uuid);
      await deleteNoteUsecase(note);

      _notes.removeWhere((n) => n.uuid == uuid);
      _trashedNotes.insert(0, note);
      _totalNotes = (_totalNotes > 0) ? _totalNotes - 1 : 0;
      _status = NoteStatus.success;
      _message = 'Ghi chú được chuyển vào thùng rác.';
      await getTrashedNotes();
      notifyListeners();
    } catch (e) {
      _status = NoteStatus.error;
      _message = 'Xóa ghi chú thât bại: $e';
      notifyListeners();
    }
  }

  Future<void> restoreNote(String uuid) async {
    try {
      final note = _trashedNotes.firstWhere((n) => n.uuid == uuid);
      await restoreNoteUsecase(note);

      _trashedNotes.removeWhere((n) => n.uuid == uuid);
      await getNotes('', 'updatedAt', 1, 1, 20);
      await getTrashedNotes();
      _status = NoteStatus.success;
      _message = 'Ghi chú đã được khôi phục.';
      notifyListeners();
    } catch (e) {
      _status = NoteStatus.error;
      _message = 'Khôi phục ghi chú thất bại: $e';
      notifyListeners();
    }
  }

  Future<void> permanentlyDeleteNote(String uuid) async {
    try {
      final note = _trashedNotes.firstWhere((n) => n.uuid == uuid);
      await permanentlyDeleteNoteUsecase(note);
      _trashedNotes.removeWhere((n) => n.uuid == uuid);
      await getTrashedNotes();
      _status = NoteStatus.success;
      _message = 'Ghi chú đã được xóa vĩnh viễn.';
      notifyListeners();
    } catch (e) {
      _status = NoteStatus.error;
      _message = 'Xóa vĩnh viễn ghi chú thất bại: $e';
      notifyListeners();
      rethrow;
    }
  }
}
