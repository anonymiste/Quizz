import 'package:flutter/foundation.dart';
import 'package:quizz_interface/models/statistics.dart';
import 'package:quizz_interface/models/users.dart';
import 'package:quizz_interface/providers/auth.dart';
import 'package:quizz_interface/services/statistics.api.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsApiService _statisticsApiService;
  final AuthProvider _authProvider;

  StatisticsModel? _userStatistics;
  bool _isLoading = false;
  String _errorMessage = '';
  List<LeaderboardEntry> _leaderboard = [];

  StatisticsProvider(this._authProvider)
      : _statisticsApiService = StatisticsApiService(
          getTokenCallback: () => Future.value(_authProvider.token),
        );

  StatisticsModel? get userStatistics => _userStatistics;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  bool get hasStatistics => _userStatistics != null;
  List<LeaderboardEntry> get leaderboard => _leaderboard;

  Future<void> loadUserStatistics({required dynamic userData}) async {
    _setLoading(true);
    _errorMessage = '';


    try {
      UserModel userModel;
      if (userData is UserModel) {
        userModel = userData;
      } else if (userData is Map<String, dynamic>) {
        userModel = UserModel.fromJson(userData);
      } else {
        throw Exception('Format de données utilisateur invalide');
      }

      _userStatistics = await _statisticsApiService.getUserStatistics(userModel);
      _errorMessage = ''; // Clear error on success
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des statistiques';
      print('❌ Erreur provider stats: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLeaderboard({int limit = 10}) async {
    try {
      _leaderboard = await _statisticsApiService.getLeaderboard(limit: limit);
      notifyListeners();
    } catch (e) {
      print('❌ Erreur chargement leaderboard: $e');
      _leaderboard = [];
      notifyListeners();
    }
  }

  Future<void> reloadUserStatistics(UserModel user) async {
    await loadUserStatistics(userData: user);
    await loadLeaderboard();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Méthodes utilitaires pour l'UI
  String getSuccessRateText() {
    if (_userStatistics == null) return '0%';
    return '${_userStatistics!.statistics.successRate.toStringAsFixed(1)}%';
  }

  String getRankText() {
    return _userStatistics?.rank.rank ?? 'Nouveau';
  }

  int getLevel() {
    return _userStatistics?.rank.level ?? 1;
  }

  int getTotalPoints() {
    return _userStatistics?.statistics.totalPoints ?? 0;
  }

  int getQuizzesCompleted() {
    return _userStatistics?.statistics.quizzesCompleted ?? 0;
  }
}