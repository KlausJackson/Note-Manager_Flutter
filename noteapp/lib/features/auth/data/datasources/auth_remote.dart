import 'package:noteapp/core/network/api_client.dart';

class AuthRemote {
  final ApiClient apiClient;
  AuthRemote({required this.apiClient});

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.post('/auth/login', {
      'username': username,
      'password': password,
    });
    return response;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.post('/auth/register', {
      'username': username,
      'password': password,
    });
    return response;
  }

  Future<void> deleteUser({required String password}) async {
    await apiClient.delete('/auth/me', data: {'password': password});
  }
}
