import 'package:dio/dio.dart';
import 'package:quizz_interface/models/statistics.dart';
import 'package:quizz_interface/models/users.dart';

class StatisticsApiService {
  final Dio _dio;
  final Future<String?> Function()? _getTokenCallback;

  StatisticsApiService({Future<String?> Function()? getTokenCallback})
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
                print('🔑 Token ajouté aux statistiques');
              }
            } catch (e) {
              print('❌ Erreur token statistiques: $e');
            }
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<StatisticsModel> getUserStatistics(UserModel userData) async {
    try {
      print('🔄 Requête API stats pour user ID: ${userData.id}');
      
      final response = await _dio.get(
        '/statistics/${userData.id}',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      print('✅ Réponse API stats: ${response.statusCode}');

      switch (response.statusCode) {
        case 200:
          final responseData = response.data;
          print('📊 Données stats reçues: $responseData');
          
          // Gérer différents formats de réponse
          if (responseData['statistiques'] != null) {
            return StatisticsModel.fromJson(responseData['statistiques']);
          } else if (responseData['data'] != null) {
            return StatisticsModel.fromJson(responseData['data']);
          } else {
            return StatisticsModel.fromJson(responseData);
          }
        
        case 404:
          print('📊 Aucune statistique trouvée, utilisation des données par défaut');
          return _getDefaultStatistics(userData);
        
        case 401:
          throw Exception('Non authentifié. Veuillez vous reconnecter.');
        
        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio stats: ${e.message}');
      print('📡 Response stats: ${e.response?.data}');
      
      // En cas d'erreur de connexion, retourner des données par défaut
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        print('🌐 Timeout connexion, retour données par défaut');
        return _getDefaultStatistics(userData);
      }
      
      throw Exception(e.response?.data?['message'] ?? 'Erreur de connexion');
    } catch (e) {
      print('❌ Erreur inattendue stats: $e');
      // Retourner des données par défaut en cas d'erreur inattendue
      return _getDefaultStatistics(userData);
    }
  }

  StatisticsModel _getDefaultStatistics(UserModel userData) {
    return StatisticsModel(
      user: UserStatsUser(
        id: userData.id ?? 0,
        name: userData.name ?? 'Utilisateur',
        email: userData.email,
        role: userData.role,
      ),
      statistics: UserStatsStatistics(
        totalPoints: 0,
        quizzesCompleted: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        successRate: 0.0,
        currentStreak: 0,
        bestStreak: 0,
        totalTimeSpent: 0,
        averageScore: 0.0,
      ),
      phasesProgress: [
        UserStatsPhase(phase: 'Débutant', progress: 0, points: 0),
      ],
      rank: UserStatsRank(rank: 'Nouveau', level: 1),
      recentActivity: [
        UserStatsRecentActivity(quiz: 'Premier quiz', score: 0, date: DateTime.now().toString()),
      ],
    );
  }

  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/statistics/leaderboard',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((entry) => LeaderboardEntry.fromJson(entry))
            .toList();
      } else {
        // Retourner un classement vide en cas d'erreur
        return [];
      }
    } catch (e) {
      print('❌ Erreur leaderboard: $e');
      return [];
    }
  }
}