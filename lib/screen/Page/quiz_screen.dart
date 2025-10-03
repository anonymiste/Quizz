import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;
  const QuizScreen({super.key, required this.quizData});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  List<int> _userAnswers = [];

  @override
  Widget build(BuildContext context) {
    final questions = widget.quizData['questions'] ?? [];
    final currentQuestion = _currentQuestionIndex < questions.length 
        ? questions[_currentQuestionIndex] 
        : null;

    if (currentQuestion == null) {
      return _buildQuizCompleted();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizData['title'] ?? 'Quiz'),
        backgroundColor: const Color.fromARGB(255, 74, 111, 165),
        foregroundColor: Colors.white,
        actions: [
          Text('${_currentQuestionIndex + 1}/${questions.length}'),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              color: const Color.fromARGB(255, 74, 111, 165),
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${_currentQuestionIndex + 1}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              currentQuestion['text'] ?? 'Question sans texte',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ..._buildAnswerOptions(currentQuestion['options'] ?? []),
            const Spacer(),
            _buildNavigationButtons(questions.length),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswerOptions(List<dynamic> options) {
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value.toString();
      
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        color: _selectedAnswerIndex == index 
            ? const Color.fromARGB(255, 74, 111, 165).withOpacity(0.1)
            : null,
        child: ListTile(
          title: Text(option),
          leading: Radio<int>(
            value: index,
            groupValue: _selectedAnswerIndex,
            onChanged: (value) => setState(() => _selectedAnswerIndex = value),
          ),
          onTap: () => setState(() => _selectedAnswerIndex = index),
        ),
      );
    }).toList();
  }

  Widget _buildNavigationButtons(int totalQuestions) {
    return Row(
      children: [
        if (_currentQuestionIndex > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _goToPreviousQuestion,
              child: const Text('Précédent'),
            ),
          ),
        if (_currentQuestionIndex > 0) const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedAnswerIndex != null ? _goToNextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 74, 111, 165),
            ),
            child: Text(
              _currentQuestionIndex == totalQuestions - 1 ? 'Terminer' : 'Suivant',
            ),
          ),
        ),
      ],
    );
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswerIndex = _userAnswers.isNotEmpty && _userAnswers.length > _currentQuestionIndex 
            ? _userAnswers[_currentQuestionIndex] 
            : null;
      });
    }
  }

  void _goToNextQuestion() {
    if (_selectedAnswerIndex != null) {
      // Sauvegarder la réponse
      if (_userAnswers.length <= _currentQuestionIndex) {
        _userAnswers.add(_selectedAnswerIndex!);
      } else {
        _userAnswers[_currentQuestionIndex] = _selectedAnswerIndex!;
      }

      if (_currentQuestionIndex < (widget.quizData['questions']?.length ?? 0) - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswerIndex = _userAnswers.length > _currentQuestionIndex 
              ? _userAnswers[_currentQuestionIndex] 
              : null;
        });
      } else {
        // Quiz terminé
        _showQuizResults();
      }
    }
  }

  void _showQuizResults() {
    final questions = widget.quizData['questions'] ?? [];
    int correctAnswers = 0;
    
    for (int i = 0; i < questions.length && i < _userAnswers.length; i++) {
      if (_userAnswers[i] == questions[i]['correct_answer_index']) {
        correctAnswers++;
      }
    }
    
    final score = (correctAnswers / questions.length * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Terminé !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $score%'),
            Text('$correctAnswers/${questions.length} réponses correctes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voir les réponses'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retour aux quiz'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCompleted() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Terminé'),
        backgroundColor: const Color.fromARGB(255, 74, 111, 165),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, size: 64, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Quiz terminé !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Merci d\'avoir participé à ce quiz.'),
          ],
        ),
      ),
    );
  }
}