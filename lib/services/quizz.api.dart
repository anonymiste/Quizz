import 'package:quizz_interface/models/quizz.dart';
import 'package:quizz_interface/models/questions.dart';
import 'package:quizz_interface/models/reponse.dart';

class QuizzApiService {
  Future<List<Quizz>> getQuizzes() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      Quizz(
        id: '1',
        title: 'Dart & Flutter Basics',
        description: 'Maîtrisez les bases de Dart et Flutter',
        category: 'programming',
        difficulty: 'beginner',
        status: 'published',
        questions: _generateQuestions(5),
        bestScore: 85,
        timeLimit: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        participants: 150,
        rating: 4.5,
      ),
      Quizz(
        id: '2',
        title: 'Python Avancé',
        description: 'Concepts avancés de Python',
        category: 'programming',
        difficulty: 'advanced',
        status: 'published',
        questions: _generateQuestions(10),
        bestScore: null,
        timeLimit: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        participants: 89,
        rating: 4.2,
      ),
    ];
  }

  List<Question> _generateQuestions(int count) {
    return List.generate(
      count,
      (index) => Question(
        id: '${index + 1}',
        text: 'Question exemple ${index + 1}?',
        reponses: [
          Reponse(
            body: 'Option A',
            value: 'A',
            check: index % 4 == 0, // Une seule réponse correcte
            questionId: '${index + 1}',
          ),
          Reponse(
            body: 'Option A',
            value: 'A',
            check: index % 4 == 1, // Une seule réponse correcte
            questionId: '${index + 1}',
          ),
          Reponse(
            body: 'Option A',
            value: 'A',
            check: index % 4 == 2, // Une seule réponse correcte
            questionId: '${index + 1}',
          ),
        ],
        correctAnswerIndex: index % 4,
        explanation: 'Explication détaillée',
      ),
    );
  }

  Future<void> deleteQuiz(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
