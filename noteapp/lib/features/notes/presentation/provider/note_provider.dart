import 'package:flutter/material.dart';
import 'package:noteapp/features/auth/presentation/provider/auth_provider.dart';

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

  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _authProvider.addListener(_onUserChanged);
    _currentUser = _authProvider.currentUser;
  }

  void _onUserChanged() {
    if (_authProvider.currentUser != _currentUser) {
      getNotes('', 'updatedAt', 1, 1, 20);
      _currentUser = _authProvider.currentUser;
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onUserChanged);
    super.dispose();
  }

  // --- State Properties ---
  late AuthProvider _authProvider;
  NoteStatus _status = NoteStatus.initial;
  String _message = '';
  List<Note> _notes = [];
  List<Note> _trashedNotes = [];
  int _totalNotes = 0;
  String _currentUser = 'default';

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

  // --- Private Helper Methods ---
  void _setMessage(String msg, bool isError) {
    _status = isError ? NoteStatus.error : NoteStatus.success;
    _message = msg;
  }

  Future<void> _execute(Future<void> Function() action, String success) async {
    try {
      await action();
      _setMessage(success, false);
    } catch (e) {
      _setMessage('Có lỗi: $e', true);
    }
    notifyListeners();
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
      _setMessage('Có lỗi khi lấy ghi chú: $e', true);
    }
    notifyListeners();
  }

  Future<void> createNote(Note note) async {
    await _execute(() async {
      await createNoteUsecase(note);
      await getNotes('', 'updatedAt', 1, 1, 20);
    }, 'Đã tạo ghi chú mới.');
  }

  Future<void> updateNote(Note note) async {
    await _execute(() async {
      await updateNoteUsecase(note);
      await getNotes('', 'updatedAt', 1, 1, 20);
    }, 'Đã cập nhật ghi chú.');
  }

  void clearNotes() {
    _notes = [];
    notifyListeners();
  }

  Future<void> performSync() async {
    _status = NoteStatus.loading;
    notifyListeners();

    await _execute(() async {
      bool isSucceed = await syncNotesUsecase();
      if (!isSucceed) {
        throw Exception('Không thể đồng bộ hóa ghi chú.');
      }
      await getNotes('', 'updatedAt', 1, 1, 20); // refresh notes
    }, 'Đã đồng bộ hóa ghi chú.');
  }

  Future<void> getTrashedNotes() async {
    _status = NoteStatus.loading;
    notifyListeners();

    try {
      _trashedNotes = await getTrashedNotesUsecase();
      _status = NoteStatus.success;
    } catch (e) {
      _setMessage('Có lỗi khi xem thùng rác: $e', true);
    }
    notifyListeners();
  }

  Future<void> deleteNote(Note note) async {
    await _execute(() async {
      bool isSuccess = await deleteNoteUsecase(note);
      if (!isSuccess) {
        throw Exception('Không thể xóa ghi chú.');
      }
      _notes.removeWhere((n) => n.uuid == note.uuid);
      _totalNotes--;
    }, 'Ghi chú được chuyển vào thùng rác.');
    notifyListeners();
  }

  Future<void> restoreNote(Note note) async {
    await _execute(() async {
      bool isSuccess = await restoreNoteUsecase(note);
      if (!isSuccess) {
        throw Exception('Không thể khôi phục ghi chú.');
      }
      await getTrashedNotes(); // refresh trashed notes
    }, 'Đã khôi phục ghi chú từ thùng rác.');
  }

  Future<void> permanentlyDeleteNote(Note note) async {
    await _execute(() async {
      bool isSuccess = await permanentlyDeleteNoteUsecase(note);
      if (!isSuccess) {
        throw Exception('Không thể xóa vĩnh viễn ghi chú.');
      }
      await getTrashedNotes(); // refresh trashed notes
    }, 'Đã xóa vĩnh viễn ghi chú.');
  }
}
