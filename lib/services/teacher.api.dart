// services/teacher_api_service.dart
import 'package:dio/dio.dart';
import 'package:quizz_interface/models/cours.dart';
import 'package:quizz_interface/models/quizz.dart';

class TeacherApiService {
  final Dio _dio;
  final Future<String?> Function()? _getTokenCallback;

  TeacherApiService({Future<String?> Function()? getTokenCallback})
    : _getTokenCallback = getTokenCallback,
      _dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api',
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
          if (_getTokenCallback != null) {
            try {
              final token = await _getTokenCallback();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              print('❌ Erreur token teacher: $e');
            }
          }
          return handler.next(options);
        },
      ),
    );
  }

  // === COURSES ===

  Future<List<Course>> getTeacherCourses(int teacherId) async {
    try {
      final response = await _dio.get(
        '/teachers/$teacherId/courses',
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 200:
          final responseData = response.data;

          if (responseData['success'] == true && responseData['data'] != null) {
            return (responseData['data'] as List)
                .map((json) => Course.fromJson(json))
                .toList();
          } else {
            return [];
          }

        case 404:
          return [];

        case 401:
          throw Exception('Non authentifié. Veuillez vous reconnecter.');

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return [];
      }
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur de chargement des cours',
      );
    } catch (e) {
      return [];
    }
  }

  Future<Course> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _dio.post(
        '/courses',
        data: courseData,
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 201:
          final responseData = response.data;

          if (responseData['success'] == true && responseData['data'] != null) {
            return Course.fromJson(responseData['data']);
          } else {
            throw Exception('Réponse invalide du serveur');
          }

        case 422:
          final errors = response.data['errors'];
          final errorMessage = errors != null
              ? errors.entries
                    .map((e) => '${e.key}: ${e.value.join(', ')}')
                    .join('\n')
              : 'Erreur de validation';
          throw Exception(errorMessage);

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur lors de la création du cours',
      );
    }
  }

  Future<void> updateCourse(
    int courseId,
    Map<String, dynamic> courseData,
  ) async {
    try {
      final response = await _dio.put(
        '/courses/$courseId',
        data: courseData,
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 200:
          return;

        case 404:
          throw Exception('Cours non trouvé');

        case 422:
          final errors = response.data['errors'];
          final errorMessage = errors != null
              ? errors.entries
                    .map((e) => '${e.key}: ${e.value.join(', ')}')
                    .join('\n')
              : 'Erreur de validation';
          throw Exception(errorMessage);

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Erreur lors de la mise à jour du cours',
      );
    }
  }

  Future<void> updateCourseStatus(int courseId, String status) async {
    try {
      final response = await _dio.patch(
        '/courses/$courseId/status',
        data: {'status': status},
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 200:
          return;

        case 404:
          throw Exception('Cours non trouvé');

        case 422:
          throw Exception('Statut invalide');

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Erreur lors de la mise à jour du statut',
      );
    }
  }

  Future<Map<String, dynamic>> getCourseStatistics(int courseId) async {
    try {
      final response = await _dio.get(
        '/courses/$courseId/statistics',
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 200:
          final responseData = response.data;

          if (responseData['success'] == true && responseData['data'] != null) {
            return responseData['data'];
          } else {
            return {};
          }

        case 404:
          throw Exception('Cours non trouvé');

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Erreur lors du chargement des statistiques',
      );
    }
  }

  // === QUIZZES ===

  Future<List<Quizz>> getTeacherQuizzes(int teacherId) async {
    try {
      print('🔄 Chargement des quiz du teacher ID: $teacherId');

      final response = await _dio.get(
        '/teachers/$teacherId/quizzes',
        options: Options(validateStatus: (status) => status! < 500),
      );

      print('✅ Réponse quiz teacher: ${response.statusCode}');
      print('📊 Données reçues: ${response.data}');

      switch (response.statusCode) {
        case 200:
          final responseData = response.data;

          // Gérer différents formats de réponse
          if (responseData is Map && responseData['success'] == true) {
            if (responseData['data'] != null) {
              return (responseData['data'] as List)
                  .map((json) => Quizz.fromJson(json))
                  .toList();
            } else if (responseData['quizzes'] != null) {
              return (responseData['quizzes'] as List)
                  .map((json) => Quizz.fromJson(json))
                  .toList();
            }
          }
          // Si la réponse est directement une liste
          else if (responseData is List) {
            return responseData.map((json) => Quizz.fromJson(json)).toList();
          }

          print('⚠️ Format de réponse non reconnu');
          return [];

        case 404:
          print('📊 Aucun quiz trouvé pour ce teacher');
          return [];

        case 401:
          throw Exception('Non authentifié. Veuillez vous reconnecter.');

        default:
          throw Exception(
            'Erreur serveur: ${response.statusCode} - ${response.data}',
          );
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio quiz teacher: ${e.message}');
      print('📡 Response quiz teacher: ${e.response?.data}');
      print('🌐 Type erreur: ${e.type}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        print('🌐 Timeout connexion, retour liste vide');
        return [];
      }

      final errorMessage =
          e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Erreur de chargement des quiz';
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ Erreur inattendue quiz teacher: $e');
      return [];
    }
  }

  Future<Quizz> createQuiz(Map<String, dynamic> quizData) async {
    try {
      final response = await _dio.post(
        '/quizzes',
        data: quizData,
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 201:
          final responseData = response.data;

          if (responseData['success'] == true && responseData['data'] != null) {
            return Quizz.fromJson(responseData['data']);
          } else if (responseData['quiz'] != null) {
            return Quizz.fromJson(responseData['quiz']);
          } else {
            return Quizz.fromJson(responseData);
          }

        case 422:
          final errors = response.data['errors'];
          final errorMessage = errors != null
              ? errors.entries
                    .map((e) => '${e.key}: ${e.value.join(', ')}')
                    .join('\n')
              : 'Erreur de validation';
          throw Exception(errorMessage);

        case 401:
          throw Exception('Non authentifié. Veuillez vous reconnecter.');

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur lors de la création du quiz',
      );
    }
  }

  Future<Quizz> updateQuiz(int quizId, Map<String, dynamic> quizData) async {
    try {
      final response = await _dio.put(
        '/quizzes/$quizId',
        data: quizData,
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 200:
          final responseData = response.data;

          if (responseData['success'] == true && responseData['data'] != null) {
            return Quizz.fromJson(responseData['data']);
          } else if (responseData['quiz'] != null) {
            return Quizz.fromJson(responseData['quiz']);
          } else {
            return Quizz.fromJson(responseData);
          }

        case 404:
          throw Exception('Quiz non trouvé');

        case 422:
          final errors = response.data['errors'];
          final errorMessage = errors != null
              ? errors.entries
                    .map((e) => '${e.key}: ${e.value.join(', ')}')
                    .join('\n')
              : 'Erreur de validation';
          throw Exception(errorMessage);

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur lors de la mise à jour du quiz',
      );
    }
  }

  Future<Quizz> duplicateQuiz(int quizId) async {
    try {
      final response = await _dio.post(
        '/quizzes/$quizId/duplicate',
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 201:
          final responseData = response.data;

          if (responseData['success'] == true && responseData['data'] != null) {
            return Quizz.fromJson(responseData['data']);
          } else if (responseData['quiz'] != null) {
            return Quizz.fromJson(responseData['quiz']);
          } else {
            return Quizz.fromJson(responseData);
          }

        case 404:
          throw Exception('Quiz non trouvé');

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur lors de la duplication du quiz',
      );
    }
  }

  Future<void> updateQuizStatus(int quizId, String status) async {
    try {
      final response = await _dio.patch(
        '/quizzes/$quizId/status',
        data: {'status': status},
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 200:
          return;

        case 404:
          throw Exception('Quiz non trouvé');

        case 422:
          throw Exception('Statut invalide');

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Erreur lors de la mise à jour du statut',
      );
    }
  }

  Future<void> deleteQuiz(int quizId) async {
    try {
      final response = await _dio.delete(
        '/quizzes/$quizId',
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 200:
        case 204:
          return;

        case 404:
          throw Exception('Quiz non trouvé');

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Erreur lors de la suppression du quiz',
      );
    }
  }

  Future<Map<String, dynamic>> getQuizStatistics(int quizId) async {
    try {
      final response = await _dio.get(
        '/quizzes/$quizId/statistics',
        options: Options(validateStatus: (status) => status! < 500),
      );

      switch (response.statusCode) {
        case 200:
          final responseData = response.data;

          if (responseData['success'] == true && responseData['data'] != null) {
            return responseData['data'];
          } else {
            return responseData;
          }

        case 404:
          throw Exception('Quiz non trouvé');

        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Erreur lors du chargement des statistiques',
      );
    }
  }
}
