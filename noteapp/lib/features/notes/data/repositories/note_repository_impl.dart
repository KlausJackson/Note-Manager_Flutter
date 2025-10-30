import 'package:noteapp/core/network/network_info.dart';
import 'package:noteapp/features/auth/data/datasources/auth_local.dart';
import 'package:noteapp/features/notes/data/datasources/note_local.dart';
import 'package:noteapp/features/notes/data/datasources/note_remote.dart';
import 'package:noteapp/features/notes/data/models/block_model.dart';
import 'package:noteapp/features/notes/data/models/note_model.dart';
import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemote noteRemote;
  final NoteLocal noteLocal;
  final AuthLocal authLocal;
  final NetworkInfo networkInfo;

  NoteRepositoryImpl({
    required this.noteRemote,
    required this.noteLocal,
    required this.authLocal,
    required this.networkInfo,
  });

  Future<String> _getCurrentUser() async {
    final user = await authLocal.getCurrentUser();
    return user ?? 'default';
  }

  List<Note> _filterAndSortLocalNotes(
    List<NoteModel> notes, {
    String? query,
    String sortBy = 'updatedAt',
    int sortOrder = 1,
  int page = 1,
    int pageSize = 20,
    bool isDeleted = false,
  }) {
    List<NoteModel> filteredNotes = notes
        .where((note) => note.isDeleted == isDeleted)
        .toList();

    // 1. --- FILTERING ---
    if (query != null && query.isNotEmpty) {
      final lowerCaseQuery = query.toLowerCase();
      filteredNotes = filteredNotes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(lowerCaseQuery);
        final bodyMatch = note.body.any(
          (block) => block.text.toLowerCase().contains(lowerCaseQuery),
        );
        return titleMatch || bodyMatch;
      }).toList();
    }

    // 2. --- SORTING ---
    filteredNotes.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'updatedAt':
        default:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return sortOrder == 1 ? -comparison : comparison;
    });

    // 3. --- PAGINATION ---
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filteredNotes.length) {
      return []; // Return an empty list if the page is out of bounds
    }

    // Calculate the end index, ensuring it doesn't exceed the list length
    final endIndex = (startIndex + pageSize > filteredNotes.length)
        ? filteredNotes.length
        : startIndex + pageSize;
    return filteredNotes.sublist(
      startIndex,
      endIndex,
    ); // Return the paginated subset
  }

  Future<Note> _action(
    Note note,
    Future<NoteModel> Function(NoteModel) apiCall,
  ) async {
    final user = await _getCurrentUser();

    final noteModel = NoteModel(
      uuid: note.uuid,
      title: note.title,
      body: note.body
          .map(
            (b) => BlockModel(type: b.type, text: b.text, checked: b.checked),
          )
          .toList(),
      isPinned: note.isPinned,
      tagUUIDs: note.tagUUIDs,
      isDeleted: note.isDeleted,
      updatedAt: DateTime.now(), 
    );


    NoteModel noteToSave = noteModel;
    if (await networkInfo.isConnected) {
      try {
        noteToSave = await apiCall(noteModel);
      } catch (e) {
        // print("API action failed");
      }
    }
    await noteLocal.upsertNote(user, noteToSave);
    return noteToSave;
  }

  @override
  Future<Note> createNote(Note note) async {
    return _action(note, noteRemote.createNote);
  }

  @override
  Future<Note> updateNote(Note note) async {
    return _action(note, noteRemote.updateNote);
  }

  @override
  Future<Map<String, dynamic>> getNotes(
    String? query, 
    String sortBy,
    int sortOrder,
    int page,
    int pageSize,
  ) async {
    final user = await _getCurrentUser();
    if (await networkInfo.isConnected && user != 'default') {
      try {
        Map<String, dynamic> queryParameters = {
          'keywords': query ?? '',
          'sortBy': '$sortBy:${sortOrder == 1 ? 'desc' : 'asc'}',
          'skip': (page - 1) * pageSize,
          'limit': pageSize,
        };
        final result = await noteRemote.getNotes(queryParameters);
        final List<NoteModel> serverNotes = (result['notes'] as List)
            .map((json) => NoteModel.fromJson(json))
            .toList();
        final int total = result['total'] ?? serverNotes.length;
        return {'notes': serverNotes, 'total': total};
      } catch (e) {
        // print("Sync failed");
      }
    }

    final localNotes = await noteLocal.getNotes(user);
    final notes = _filterAndSortLocalNotes(
      localNotes,
      query: query,
      sortBy: sortBy,
      sortOrder: sortOrder,
      page: page,
      pageSize: pageSize,
      isDeleted: false,
    );
    return {'notes': notes, 'total': localNotes.length};
  }

  // SYNC FAILED
  @override
  Future<void> syncNotes() async {
    if (!await networkInfo.isConnected) {
      return;
    }

    // 2. PREPARE DATA
    final user = await _getCurrentUser();
    final lastSyncedAt = (await authLocal.getLastSynced(user));

    final List<NoteModel> allLocalNotes = await noteLocal.getNotes(user);
    final List<NoteModel> notesToSync = allLocalNotes
        .where(
          (note) => note.updatedAt.isAfter(
            lastSyncedAt != null
                ? DateTime.parse(lastSyncedAt)
                : DateTime.fromMillisecondsSinceEpoch(0),
          ),
        ) // all notes if never synced
        .toList();

    final List<NoteModel> updated = notesToSync
        .where((note) => !note.isDeleted)
        .toList();
    final List<NoteModel> deleted = notesToSync
        .where((note) => note.isDeleted)
        .toList();

    final notesPayload = {
      'created': [],
      'updated': updated.map((n) => n.toJson()).toList(),
      'deleted': deleted.map((n) => n.toJson()).toList(),
    };

    final fullPayload = {
      'lastSynced': lastSyncedAt,
      'notes': notesPayload,
      'tags': {},
    };

    try {
      // 3. SEND TO SERVER
      final response = await noteRemote.syncNotes(fullPayload);

      final List<NoteModel> serverNotes = (response['notes'] as List)
          .map((json) => NoteModel.fromJson(json))
          .toList();
      final newTimestamp = response['timestamp'];

      // 4. UPDATE LOCAL DATABASE
      await noteLocal.upsertNotes(user, serverNotes);
      await authLocal.updateLastSynced(user, newTimestamp);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE, PERMANENT DELETE, RESTORE, GET TRASHED
  @override
  Future<void> deleteNote(String? uuid) async {
    if (uuid == null) return;
    final user = await _getCurrentUser();
    final localNotes = await noteLocal.getNotes(user);
    final index = localNotes.indexWhere((n) => n.uuid == uuid);
    if (index == -1) return;
    final note = localNotes[index];
    final updated = NoteModel(
      uuid: note.uuid,
      title: note.title,
      body: note.body,
      isPinned: note.isPinned,
      tagUUIDs: note.tagUUIDs,
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
    // try remote if connected; update local with server response when available
    try {
      if (await networkInfo.isConnected) {
        final serverNote = await noteRemote.deleteNote(uuid);
        await noteLocal.upsertNote(user, serverNote);
        return;
      }
    } catch (e) {
      // Surface remote errors to caller so UI can show them
      rethrow;
    }
    await noteLocal.upsertNote(user, updated);
  }

  @override
  Future<void> permanentlyDeleteNote(String? uuid) async {
    if (uuid == null) return;
    final user = await _getCurrentUser();
    try {
      if (await networkInfo.isConnected) {
        await noteRemote.permanentlyDeleteNote(uuid);
        await noteLocal.deleteNote(user, uuid);
        return;
      }
    } catch (e) {
      rethrow;
    }
    await noteLocal.deleteNote(user, uuid);
  }

  @override
  Future<List<Note>> getTrashedNotes() async {
    // Mirror getNotes: prefer server when connected and user is set
    final user = await _getCurrentUser();
    if (await networkInfo.isConnected && user != 'default') {
      try {
        final queryParameters = {'skip': 0, 'limit': 1000};
        final result = await noteRemote.getTrashedNotes(queryParameters);
    final List<NoteModel> serverNotes = (result['notes'] as List)
      .map((json) => NoteModel.fromJson(json))
      .where((n) => n.isDeleted == true)
      .toList();
    return serverNotes;
      } catch (e) {
        // fallback to local
      }
    }

    final localNotes = await noteLocal.getNotes(user);
    final trashedNotes = _filterAndSortLocalNotes(localNotes, isDeleted: true);
    return trashedNotes;
  }

  @override
  Future<void> restoreNote(String? uuid) async {
    if (uuid == null) return;
    final user = await _getCurrentUser();
    final localNotes = await noteLocal.getNotes(user);
    final index = localNotes.indexWhere((n) => n.uuid == uuid);
    if (index == -1) return;
    final note = localNotes[index];
    final updated = NoteModel(
      uuid: note.uuid,
      title: note.title,
      body: note.body,
      isPinned: note.isPinned,
      tagUUIDs: note.tagUUIDs,
      isDeleted: false,
      updatedAt: DateTime.now(),
    );
    try {
      if (await networkInfo.isConnected) {
        final serverNote = await noteRemote.restoreNote(uuid);
        await noteLocal.upsertNote(user, serverNote);
        return;
      }
    } catch (e) {
      rethrow;
    }
    await noteLocal.upsertNote(user, updated);
  }
}
