import 'package:dio/dio.dart';
import 'package:quizz_interface/models/users.dart';

class AdminApiService {
  final Dio _dio;
  final Future<String?> Function() _getTokenCallback;

  AdminApiService({required Future<String?> Function() getTokenCallback})
    : _getTokenCallback = getTokenCallback,
      _dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api/admin',
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getTokenCallback();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/dashboard-stats');
      // print('📊 Données brutes dashboard: ${response.data}');
      if (response.data['stats'] != null) {
        response.data['stats'].forEach((key, value) {});
      }

      response.data['stats'].forEach((key, value) {
        // Vérification spécifique pour les nombres
        if (key.contains('total') ||
            key.contains('points') ||
            key.contains('attempts')) {
          if (value is String) {
            print(
              '   ⚠️  ATTENTION: $key est une String mais devrait être un nombre',
            );
          }
        }
      });
      return response.data['stats'];
    } on DioException catch (e) {
      print('🔴 ERREUR DIO détaillée:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   URL: ${e.requestOptions.uri}');
      print('   Méthode: ${e.requestOptions.method}');
      print('   Headers: ${e.requestOptions.headers}');
      print('   Data: ${e.requestOptions.data}');
      print('   Response: ${e.response?.data}');

      rethrow;
    } catch (e, stackTrace) {
      print('🔴 ERREUR INATTENDUE:');
      print('   Message: $e');
      print('   StackTrace: $stackTrace');
      rethrow;
    }
  }

  // System Analytics
  Future<Map<String, dynamic>> getSystemAnalytics() async {
    try {
      final response = await _dio.get('/system-analytics');
      return response.data['analytics'];
    } on DioException catch (e) {
      print(e.response);
      throw Exception(e.response?.data?['message'] ?? 'Erreur analytics');
    }
  }

  // Users Management
  Future<Response> getUsers({
    // Retourner Response directement
    int page = 1,
    int perPage = 10,
    String? search,
    String? role,
  }) async {
    try {
      final response = await _dio.get(
        '/users',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null) 'search': search,
          if (role != null) 'role': role,
        },
      );

      // Retourner la réponse complète
      // print(response);
      return response;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur récupération utilisateurs',
      );
    }
  }

  // Create User
  Future<Response> createUser(UserModel newUser) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'name': newUser.name ?? "",
          'email': newUser.email,
          'role': newUser.role,
          'total': newUser.total ?? 0,
        },
      );
      final user = UserModel.fromJson(response.data['user']);
      // print('✅ Utilisateur créé avec succès: ${response.statusCode}');
      // print('📦 Réponse: ${response.data}');
      return response;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur création utilisateur',
      );
    }
  }

  // Update User
  Future<Response> updateUser(UserModel userData) async {
    try {
      final response = await _dio.put(
        '/users/${userData.id}',
        data: {
          'name': userData.name,
          'email': userData.email,
          'role': userData.role,
          'total': userData.total ?? 0,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur mise à jour utilisateur',
      );
    }
  }

  // Delete User
  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete('/users/$userId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur suppression utilisateur',
      );
    }
  }

  // Get Quizzes
  Future<Response> getQuizzes({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/quizzes',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null) 'search': search,
        },
      );
      return response;
    } on DioException catch (e) {
      print(e.response);
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur récupération quizzes',
      );
    }
  }
}
