
import 'package:noteapp/core/network/api_client.dart';
import 'package:noteapp/features/notes/data/models/note_model.dart';

class NoteRemote {
  final ApiClient apiClient;
  NoteRemote({required this.apiClient});

  Future<Map<String, dynamic>> getNotes(
    Map<String, dynamic> queryParameters,
  ) async {
    final response = await apiClient.get(
      '/notes',
      queryParameters: queryParameters,
    );
    return response['data'];
  }

  Future<NoteModel> createNote(NoteModel note) async {
    final response = await apiClient.post('/notes', note.toJson());
    return NoteModel.fromJson(response['data']);
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    final response = await apiClient.put('/notes/${note.uuid}', note.toJson());
    return NoteModel.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> syncNotes(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.post('/sync', payload);
      return {
        'notes': (response['data']['notes'] as List)
            .map((json) => NoteModel.fromJson(json))
            .toList(),
        'timestamp': response['data']['timestamp'],
      };
    } catch (e) {
      rethrow; // Rethrow the formatted exception from ApiClient
    }
  }

  // Implement deleteNote, getTrashedNotes, permanentlyDeleteNote, restoreNote.
  Future<NoteModel> deleteNote(String uuid) async {
    final response = await apiClient.delete('/notes/$uuid');
    return NoteModel.fromJson(response['data']);
  }

  Future<NoteModel> restoreNote(String uuid) async {
    final response = await apiClient.put('/notes/$uuid/restore', {});
    return NoteModel.fromJson(response['data']);
  }

  Future<List<NoteModel>> getTrashedNotes() async {
    final response = await apiClient.get('/notes/trash');
    return (response['data'] as List)
        .map((json) => NoteModel.fromJson(json))
        .toList();
  }

  Future<bool> permanentlyDeleteNote(String uuid) async {
    final response = await apiClient.delete('/notes/trash/$uuid');
    return response['data'];
  }
}
