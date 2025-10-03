import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:quizz_interface/models/admin_dashbord_stats.dart';
import 'package:quizz_interface/models/quizz.dart';
import 'package:quizz_interface/models/users.dart';
import 'package:quizz_interface/providers/auth.dart';
import 'package:quizz_interface/services/admin.api.dart';

class AdminProvider with ChangeNotifier {
  final AdminApiService _adminApiService;
  final AuthProvider _authProvider;

  Timer? _autoRefreshTimer;
  Timer? _dashboardTimer;
  Timer? _quizzesTimer;
  Timer? _usersTimer;
  Timer? _statsTimer;
  bool _autoRefreshEnabled = true;
  int _autoRefreshInterval = 30000; // 30 secondes
  // État avec UserModel
  bool _isActive = true;
  AdminDashboardStats? _dashboardStatsModel;
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _systemAnalytics = {};
  List<UserModel> _users = [];
  List<dynamic> _quizzes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  AdminProvider(this._authProvider)
    : _adminApiService = AdminApiService(
        getTokenCallback: () => Future.value(_authProvider.token),
      );

  // Getters
  AdminDashboardStats? get dashboardStatsModel => _dashboardStatsModel;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  Map<String, dynamic> get systemAnalytics => _systemAnalytics;
  List<UserModel> get users => _users;
  List<dynamic> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  void startAutoRefresh() {
    if (_autoRefreshTimer != null) return;

    _autoRefreshTimer = Timer.periodic(
      Duration(milliseconds: _autoRefreshInterval),
      (timer) {
        if (_autoRefreshEnabled) {
          _autoRefreshData();
        }
      },
    );
  }

  // Méthode pour arrêter l'auto-reload
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  // Méthode pour l'auto-reload des données
  Future<void> _autoRefreshData() async {
    try {
      // Recharger uniquement les données essentielles
      await loadDashboardStats();
      // Notifier les listeners pour mettre à jour l'UI
      notifyListeners();
    } catch (e) {
      print('Auto-refresh error: $e');
    }
  }

  void startDashboardAutoRefresh() {
    if (_dashboardTimer != null) return;

    _dashboardTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_isActive) {
        loadDashboardStats();
        loadSystemAnalytics();
      }
    });
  }

  void stopDashboardAutoRefresh() {
    _dashboardTimer?.cancel();
    _dashboardTimer = null;
  }

  void startQuizzesAutoRefresh() {
    if (_quizzesTimer != null) return;

    _quizzesTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_isActive) {
        loadQuizzes();
      }
    });
  }

  void stopQuizzesAutoRefresh() {
    _quizzesTimer?.cancel();
    _quizzesTimer = null;
  }

  void startUsersAutoRefresh() {
    if (_usersTimer != null) return;

    _usersTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_isActive) {
        loadUsers();
      }
    });
  }

  void stopUsersAutoRefresh() {
    _usersTimer?.cancel();
    _usersTimer = null;
  }

  void startStatsAutoRefresh() {
    if (_statsTimer != null) return;

    _statsTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_isActive) {
        loadSystemAnalytics();
      }
    });
  }

  void stopStatsAutoRefresh() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  // Nettoyer tous les timers
  void disposeTimers() {
    stopDashboardAutoRefresh();
    stopQuizzesAutoRefresh();
    stopUsersAutoRefresh();
    stopStatsAutoRefresh();
  }

  // Dashboard Stats
  Future<void> loadDashboardStats() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = '';

    try {
      final stats = await _adminApiService.getDashboardStats();
      _dashboardStats = stats;
      _dashboardStatsModel = AdminDashboardStats.fromJson(stats);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      print(_errorMessage);
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // System Analytics
  Future<void> loadSystemAnalytics() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = '';

    try {
      final analytics = await _adminApiService.getSystemAnalytics();
      _systemAnalytics = analytics;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Users Management avec UserModel
  Future<void> loadUsers({String? search, String? role}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await _adminApiService.getUsers(
        search: search,
        role: role,
      );

      // CORRECTION SIMPLE
      final usersList = response.data['users']['data'] as List? ?? [];

      _users = usersList.map((userJson) {
        return UserModel.fromJson(Map<String, dynamic>.from(userJson));
      }).toList();

      // print('✅ ${_users.length} utilisateurs chargés');
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des utilisateurs: $e';
      _users = [];
      print('Erreur loadUsers: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Create User avec UserModel
  Future<bool> createUser(UserModel userData) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await _adminApiService.createUser(userData);
      final newUser = UserModel.fromJson(response.data);
      _users.insert(0, newUser);
      _errorMessage = '';
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print(_errorMessage);
      _safeNotifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Update User avec UserModel
  Future<bool> updateUser(UserModel userData) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await _adminApiService.updateUser(userData);
      // final updatedUser = UserModel.fromJson(response);
      // final index = _users.indexWhere((user) => user.id == userData.id);
      // if (index != -1) {
      //   _users[index] = userData;
      // }
      _errorMessage = '';
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _safeNotifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Delete User
  Future<bool> deleteUser(int userId) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = '';

    try {
      await _adminApiService.deleteUser(userId);
      // _users.removeWhere((user) => user.id == userId);
      _errorMessage = '';
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _safeNotifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Quizzes Management
  Future<void> loadQuizzes({String? search}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await _adminApiService.getQuizzes(search: search);
      final quizzData = _extractQuizzesFromResponse(response.data);
      _quizzes = _parseQuizzesList(quizzData);
      print(_quizzes);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      print(errorMessage);
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  List<dynamic> _extractQuizzesFromResponse(dynamic responseData) {
    try {
      // Debug de la structure
      // print('🔍 Debug responseData:');
      // print('  - Type: ${responseData.runtimeType}');
      // if (responseData is Map) {
      //   print('  - Clés: ${responseData.keys}');
      // }

      if (responseData is! Map) return [];

      // Essayer différentes clés possibles
      final possibleKeys = ['quizz', 'data', 'quizzes', 'items', 'results'];

      for (final key in possibleKeys) {
        if (responseData.containsKey(key)) {
          final data = responseData[key];

          if (data is List) {
            return data;
          } else if (data is Map &&
              data.containsKey('data') &&
              data['data'] is List) {
            return data['data'];
          } else if (data is Map) {
            // Si c'est un objet unique, le mettre dans une liste
            return [data];
          }
        }
      }

      // Si la réponse est directement une liste
      if (responseData is List) {
        print(responseData);
      }

      return [];
    } catch (e) {
      print('❌ Erreur extraction quizzes: $e');
      return [];
    }
  }

  List<Quizz> _parseQuizzesList(List<dynamic> quizzData) {
    return quizzData
        .map((quizData) {
          try {
            if (quizData is Map<String, dynamic>) {
              return Quizz.fromJson(quizData);
            } else if (quizData is Map) {
              return Quizz.fromJson(Map<String, dynamic>.from(quizData));
            } else {
              print('⚠️ Format de quiz invalide: $quizData');
              return Quizz.fromJson({});
            }
          } catch (e) {
            print('❌ Erreur parsing quiz: $e');
            return Quizz.fromJson({});
          }
        }).toList(); // Filtrer les quiz valides
  }

  void clearError() {
    _errorMessage = '';
    _safeNotifyListeners();
  }

  // Méthode sécurisée pour notifyListeners
  void _safeNotifyListeners() {
    if (!_isLoading) {
      Future.microtask(() {
        if (hasListeners) {
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
