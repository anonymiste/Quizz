// providers/teacher_provider.dart
import 'package:flutter/foundation.dart';
import 'package:quizz_interface/models/cours.dart';
import 'package:quizz_interface/models/quizz.dart';
import 'package:quizz_interface/providers/auth.dart';
import 'package:quizz_interface/services/teacher.api.dart';

class TeacherProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  late final TeacherApiService _apiService;

  // États pour les quizzes
  List<Quizz> _quizzes = [];
  bool _isLoadingQuizzes = false;
  String _quizzesError = '';

  // États pour les cours
  List<Course> _courses = [];
  bool _isLoadingCourses = false;
  String _coursesError = '';

  // États pour les opérations
  bool _isCreatingQuiz = false;
  bool _isCreatingCourse = false;
  bool _isUpdatingQuiz = false;
  bool _isUpdatingCourse = false;

  TeacherProvider(AuthProvider authProvider) : _authProvider = authProvider {
    _apiService = TeacherApiService(
      getTokenCallback: () => Future.value(_authProvider.token),
    );

    _authProvider.addListener(_onAuthChanged);

    if (_isTeacherAuthenticated) {
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (_isTeacherAuthenticated) {
      _loadInitialData();
    } else {
      _reset();
    }
  }

  bool get _isTeacherAuthenticated =>
      _authProvider.isLoggedIn && _authProvider.currentUser?.role == 'teacher';

  int? get _teacherId => _authProvider.currentUser?.id;

  // === GETTERS ===

  // Quizzes
  List<Quizz> get quizzes => List.unmodifiable(_quizzes);
  bool get isLoadingQuizzes => _isLoadingQuizzes;
  String get quizzesError => _quizzesError;
  bool get isCreatingQuiz => _isCreatingQuiz;
  bool get isUpdatingQuiz => _isUpdatingQuiz;

  // Courses
  List<Course> get courses => List.unmodifiable(_courses);
  bool get isLoadingCourses => _isLoadingCourses;
  String get coursesError => _coursesError;
  bool get isCreatingCourse => _isCreatingCourse;
  bool get isUpdatingCourse => _isUpdatingCourse;
  bool get isTeacher => _isTeacherAuthenticated;
  bool get hasCoursesError => _coursesError.isNotEmpty;
  bool get hasQuizzesError => _quizzesError.isNotEmpty;

  // === MÉTHODES PRIVÉES ===

  Future<void> _loadInitialData() async {
    if (_teacherId == null) return;

    await Future.wait([_loadQuizzes(), _loadCourses()]);
  }

  void _reset() {
    _quizzes.clear();
    _courses.clear();
    _quizzesError = '';
    _coursesError = '';
    notifyListeners();
  }

  Future<void> _loadQuizzes() async {
    if (_teacherId == null) return;

    _isLoadingQuizzes = true;
    _quizzesError = '';
    notifyListeners();

    try {
      _quizzes = await _apiService.getTeacherQuizzes(_teacherId!);
      _quizzesError = '';
    } catch (error) {
      _quizzesError = 'Erreur lors du chargement des quizzes: $error';
      print(_quizzesError);
    } finally {
      _isLoadingQuizzes = false;
      notifyListeners();
    }
  }

  Future<void> _loadCourses() async {
    if (_teacherId == null) return;

    _isLoadingCourses = true;
    _coursesError = '';
    notifyListeners();

    try {
      _courses = await _apiService.getTeacherCourses(_teacherId!);
      _coursesError = '';
    } catch (error) {
      _coursesError = 'Erreur lors du chargement des cours: $error';
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  // === MÉTHODES PUBLIQUES POUR LES QUIZZES ===

  Future<void> refreshQuizzes() async {
    await _loadQuizzes();
  }

  Future<bool> createQuiz(Map<String, dynamic> quizData) async {
    if (!_isTeacherAuthenticated) return false;

    _isCreatingQuiz = true;
    _quizzesError = '';
    notifyListeners();

    try {
      final newQuiz = await _apiService.createQuiz(quizData);
      _quizzes.insert(0, newQuiz);
      _quizzesError = '';
      return true;
    } catch (error) {
      _quizzesError = 'Erreur lors de la création du quiz: $error';
      return false;
    } finally {
      _isCreatingQuiz = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuiz(int quizId, Map<String, dynamic> quizData) async {
    if (!_isTeacherAuthenticated) return false;

    _isUpdatingQuiz = true;
    _quizzesError = '';
    notifyListeners();

    try {
      final updatedQuiz = await _apiService.updateQuiz(quizId, quizData);
      final index = _quizzes.indexWhere((q) => q.id == quizId.toString());
      if (index != -1) {
        _quizzes[index] = updatedQuiz;
      }
      _quizzesError = '';
      return true;
    } catch (error) {
      _quizzesError = 'Erreur lors de la mise à jour du quiz: $error';
      return false;
    } finally {
      _isUpdatingQuiz = false;
      notifyListeners();
    }
  }

  Future<bool> duplicateQuiz(int quizId) async {
    if (!_isTeacherAuthenticated) return false;

    _isCreatingQuiz = true;
    _quizzesError = '';
    notifyListeners();

    try {
      final duplicatedQuiz = await _apiService.duplicateQuiz(quizId);
      _quizzes.insert(0, duplicatedQuiz);
      _quizzesError = '';
      return true;
    } catch (error) {
      _quizzesError = 'Erreur lors de la duplication du quiz: $error';
      return false;
    } finally {
      _isCreatingQuiz = false;
      notifyListeners();
    }
  }

  Future<bool> publishQuiz(int quizId) async {
    return _updateQuizStatus(quizId, 'published');
  }

  Future<bool> archiveQuiz(int quizId) async {
    return _updateQuizStatus(quizId, 'archived');
  }

  Future<bool> _updateQuizStatus(int quizId, String status) async {
    if (!_isTeacherAuthenticated) return false;

    _isUpdatingQuiz = true;
    _quizzesError = '';
    notifyListeners();

    try {
      await _apiService.updateQuizStatus(quizId, status);
      await _loadQuizzes(); // Recharger pour avoir les données à jour
      _quizzesError = '';
      return true;
    } catch (error) {
      _quizzesError = 'Erreur lors de la mise à jour du statut: $error';
      return false;
    } finally {
      _isUpdatingQuiz = false;
      notifyListeners();
    }
  }

  Future<bool> deleteQuiz(int quizId) async {
    if (!_isTeacherAuthenticated) return false;

    _isUpdatingQuiz = true;
    _quizzesError = '';
    notifyListeners();

    try {
      await _apiService.deleteQuiz(quizId);
      _quizzes.removeWhere((q) => q.id == quizId.toString());
      _quizzesError = '';
      return true;
    } catch (error) {
      _quizzesError = 'Erreur lors de la suppression du quiz: $error';
      return false;
    } finally {
      _isUpdatingQuiz = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getQuizStatistics(int quizId) async {
    if (!_isTeacherAuthenticated) return null;

    try {
      return await _apiService.getQuizStatistics(quizId);
    } catch (error) {
      _quizzesError = 'Erreur lors du chargement des statistiques: $error';
      notifyListeners();
      return null;
    }
  }

  // === MÉTHODES PUBLIQUES POUR LES COURS ===

  Future<void> refreshCourses() async {
    await _loadCourses();
  }

  Future<void> refreshAll() async {
    await _loadInitialData();
  }

  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    if (!_isTeacherAuthenticated) return false;

    _isCreatingCourse = true;
    _coursesError = '';
    notifyListeners();

    try {
      final newCourse = await _apiService.createCourse(courseData);
      _courses.insert(0, newCourse);
      _coursesError = '';
      return true;
    } catch (error) {
      _coursesError = 'Erreur lors de la création du cours: $error';
      return false;
    } finally {
      _isCreatingCourse = false;
      notifyListeners();
    }
  }

  Future<bool> updateCourse(
    int courseId,
    Map<String, dynamic> courseData,
  ) async {
    if (!_isTeacherAuthenticated) return false;

    _isUpdatingCourse = true;
    _coursesError = '';
    notifyListeners();

    try {
      await _apiService.updateCourse(courseId, courseData);

      // Mettre à jour localement
      final index = _courses.indexWhere((c) => c.id == courseId);
      if (index != -1) {
        _courses[index] = Course(
          id: courseId,
          title: courseData['title'] ?? _courses[index].title,
          description: courseData['description'] ?? _courses[index].description,
          category: courseData['category'] ?? _courses[index].category,
          teacherId: _courses[index].teacherId,
          studentCount: _courses[index].studentCount,
          quizCount: _courses[index].quizCount,
          status: courseData['status'] ?? _courses[index].status,
          average: courseData['average'] ?? _courses[index].average,
          level: courseData['level'] ?? _courses[index].level,
          createdAt: _courses[index].createdAt,
          updatedAt: DateTime.now(),
        );
      }

      _coursesError = '';
      return true;
    } catch (error) {
      _coursesError = 'Erreur lors de la mise à jour du cours: $error';
      return false;
    } finally {
      _isUpdatingCourse = false;
      notifyListeners();
    }
  }

  Future<bool> archiveCourse(int courseId) async {
    return _updateCourseStatus(courseId, 'archived');
  }

  Future<bool> activateCourse(int courseId) async {
    return _updateCourseStatus(courseId, 'active');
  }

  Future<bool> _updateCourseStatus(int courseId, String status) async {
    if (!_isTeacherAuthenticated) return false;

    _isUpdatingCourse = true;
    _coursesError = '';
    notifyListeners();

    try {
      await _apiService.updateCourseStatus(courseId, status);
      await _loadCourses(); // Recharger pour avoir les données à jour
      _coursesError = '';
      return true;
    } catch (error) {
      _coursesError = 'Erreur lors de la mise à jour du statut: $error';
      return false;
    } finally {
      _isUpdatingCourse = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getCourseStatistics(int courseId) async {
    if (!_isTeacherAuthenticated) return null;

    try {
      return await _apiService.getCourseStatistics(courseId);
    } catch (error) {
      _coursesError = 'Erreur lors du chargement des statistiques: $error';
      notifyListeners();
      return null;
    }
  }

  // === MÉTHODES UTILITAIRES ===

  Quizz? getQuizById(int quizId) {
    try {
      return _quizzes.firstWhere((q) => q.id == quizId.toString());
    } catch (e) {
      return null;
    }
  }

  Course? getCourseById(int courseId) {
    try {
      return _courses.firstWhere((c) => c.id == courseId);
    } catch (e) {
      return null;
    }
  }

  // Filtrage des quizzes
  List<Quizz> getQuizzesByStatus(String status) {
    if (status == 'all') return _quizzes;
    return _quizzes.where((quiz) => quiz.status == status).toList();
  }

  List<Quizz> searchQuizzes(String query) {
    if (query.isEmpty) return _quizzes;

    final searchLower = query.toLowerCase();
    return _quizzes
        .where(
          (quiz) =>
              quiz.title.toLowerCase().contains(searchLower) ||
              quiz.description.toLowerCase().contains(searchLower) ||
              (quiz.category?.toLowerCase().contains(searchLower) ?? false),
        )
        .toList();
  }

  // Filtrage des cours
  List<Course> getCoursesByStatus(String status) {
    if (status == 'all') return _courses;
    return _courses.where((course) => course.status == status).toList();
  }

  List<Course> searchCourses(String query) {
    if (query.isEmpty) return _courses;

    final searchLower = query.toLowerCase();
    return _courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(searchLower) ||
              course.description.toLowerCase().contains(searchLower) ||
              course.level.toLowerCase().contains(searchLower) ||
              course.category.toLowerCase().contains(searchLower),
        )
        .toList();
  }

  // Gestion des erreurs
  void clearErrors() {
    _quizzesError = '';
    _coursesError = '';
    notifyListeners();
  }

  void clearQuizError() {
    _quizzesError = '';
    notifyListeners();
  }

  void clearCourseError() {
    _coursesError = '';
    notifyListeners();
  }

  // Méthode pour forcer le rechargement des données
  Future<void> forceRefresh() async {
    _quizzes.clear();
    _courses.clear();
    notifyListeners();
    await _loadInitialData();
  }

  // Vérifier si l'utilisateur peut effectuer des actions
  bool get canPerformActions => _isTeacherAuthenticated && !isLoading;

  // Obtenir le nombre total d'éléments
  int get totalQuizzesCount => _quizzes.length;
  int get totalCoursesCount => _courses.length;

  bool get isLoading => _isLoadingQuizzes || _isLoadingCourses;
}
