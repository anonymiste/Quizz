import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quizz_interface/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService extends ChangeNotifier {
  final Dio _dio;

  AuthApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api',
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getStoredToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Response> login(String email) async {
    try {
      final response = await _dio.post('/auth/login', data: {'email': email});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? response.data['access_token'];
        if (token != null) {
          await _saveToken(token);
        }
      }
      return response;
    } on DioException catch (e) {
      print(e.message);
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Response> logout(UserModel user) async {
    try {
      final response = await _dio.post('/auth/logout');
      await _clearToken();
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Response> me() async {
    try {
      final response = await _dio.get('/auth/me');
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _clearToken();
      }
      rethrow;
    }
  }

  Future<Response> profileUpdate(UserModel updatedUser) async {
    try {
      final response = await _dio.put(
        '/auth/profile/${updatedUser.id}',
        data: updatedUser.toJson(),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Response> profileDelete(UserModel user) async {
    try {
      final response = await _dio.delete('/auth/profile/${user.id}');
      await _clearToken();
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }
}
