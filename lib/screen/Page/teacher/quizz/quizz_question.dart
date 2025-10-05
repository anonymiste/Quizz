
import 'package:flutter/material.dart';
import 'package:quizz_interface/models/questions.dart';
import 'package:quizz_interface/models/quizz.dart';
import 'package:quizz_interface/screen/Page/teacher/quizz/quizz_question_edit.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final Quizz quiz;

  const QuizQuestionsScreen({super.key, required this.quiz});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  late List<Question> _questions;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.quiz.questions);
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => QuestionEditDialog(
        quizz: widget.quiz,
        onQuestionSaved: (newQuestion) {
          setState(() {
            _questions.add(newQuestion);
          });
        },
      ),
    );
  }

  void _editQuestion(Question question, int index) {
    showDialog(
      context: context,
      builder: (context) => QuestionEditDialog(
        quizz: widget.quiz,
        question: question,
        questionIndex: index,
        onQuestionSaved: (updatedQuestion) {
          setState(() {
            _questions[index] = updatedQuestion;
          });
        },
      ),
    );
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la question'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer la question "${_questions[index].text}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _questions.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question supprimée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _reorderQuestions(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Question item = _questions.removeAt(oldIndex);
      _questions.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions - ${widget.quiz.title}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addQuestion,
            tooltip: 'Ajouter une question',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuestions,
            tooltip: 'Sauvegarder les modifications',
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          _buildQuizHeader(),
          
          // Liste des questions
          Expanded(
            child: _questions.isEmpty
                ? _buildEmptyState()
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _questions.length,
                    onReorder: _reorderQuestions,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return _buildQuestionCard(question, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuizHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          _buildStatItem(Icons.quiz, 'Questions', '${_questions.length}'),
          _buildStatItem(Icons.timer, 'Durée totale', '${_calculateTotalTime()} min'),
          _buildStatItem(Icons.score, 'Points totaux', '${_calculateTotalPoints()} pts'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalTime() {
    return _questions.length * 2; // 2 minutes par question estimées
  }

  int _calculateTotalPoints() {
    return _questions.fold(0, (sum, question) => sum + (question.points));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucune question',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Commencez par ajouter votre première question',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une question'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Card(
      key: Key('question_${question.id}_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de la question
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: const ListTile(
                        leading: Icon(Icons.edit, color: Colors.blue),
                        title: Text('Modifier'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: const ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Supprimer'),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editQuestion(question, index);
                        break;
                      case 'delete':
                        _deleteQuestion(index);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Options/réponses
            if (question.reponses.isNotEmpty) ...[
              Text(
                'Options:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ...question.reponses.asMap().entries.map((entry) {
                final reponse = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: reponse.check ? Colors.green : Colors.grey[300],
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: reponse.check
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${reponse.value}. ${reponse.body}',
                          style: TextStyle(
                            color: reponse.check ? Colors.green : Colors.grey[700],
                            fontWeight: reponse.check ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              Text(
                'Aucune option définie',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            // Métadonnées
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text('${question.points} pt${question.points != 1 ? 's' : ''}'),
                  backgroundColor: Colors.blue.shade50,
                ),
                const SizedBox(width: 8),
                if (question.explanation?.isNotEmpty ?? false)
                  Chip(
                    label: const Text('Avec explication'),
                    backgroundColor: Colors.green.shade50,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveQuestions() async {
    setState(() {
      _isLoading = true;
    });

    // Simuler la sauvegarde
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Questions sauvegardées avec succès'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
