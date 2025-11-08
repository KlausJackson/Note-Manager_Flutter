import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:noteapp/core/constants.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: Constants.apiBaseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'authToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  String _eMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      return e.response?.data['message'] ?? 'Lỗi không xác định.';
    } else {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.';
    }
  }

  // --- API METHODS ---
  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _eMessage(e);
    }
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _eMessage(e);
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _eMessage(e);
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _eMessage(e);
    }
  }
}
