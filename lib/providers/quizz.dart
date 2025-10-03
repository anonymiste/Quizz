import 'package:flutter/foundation.dart';
import 'package:quizz_interface/models/quizz.dart';
import 'package:quizz_interface/services/quizz.api.dart';

class QuizzProvider with ChangeNotifier {
  final QuizzApiService _quizzApiService;
  
  List<Quizz> _quizzes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  QuizzProvider(this._quizzApiService);

  List<Quizz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage.isNotEmpty;
  String get errorMessage => _errorMessage;

  Future<void> loadQuizzes() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _quizzes = await _quizzApiService.getQuizzes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      await _quizzApiService.deleteQuiz(quizId);
      _quizzes.removeWhere((quiz) => quiz.id == quizId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}