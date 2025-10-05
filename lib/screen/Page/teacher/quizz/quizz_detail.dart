
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quizz_interface/enums/quizz_dificulty.dart';
import 'package:quizz_interface/models/quizz.dart';
import 'package:quizz_interface/screen/Page/teacher/quizz/quizz_edit.dart';

class QuizDetailScreen extends StatelessWidget {
  final Quizz quiz;

  const QuizDetailScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Quiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareQuiz(context),
            tooltip: 'Partager le quiz',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec titre et statut
            _buildQuizHeader(),
            const SizedBox(height: 24),

            // Informations principales
            _buildQuizInfo(),
            const SizedBox(height: 24),

            // Statistiques
            _buildQuizStatistics(),
            const SizedBox(height: 24),

            // Questions
            _buildQuestionsSection(),
            const SizedBox(height: 24),

            // Actions
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.quiz,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          _getStatusLabel(quiz.status),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusColor(quiz.status),
                          ),
                        ),
                        backgroundColor: _getStatusBackgroundColor(quiz.status),
                      ),
                      Chip(
                        label: Text(
                          _getDifficultyLabel(quiz.difficulty),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getDifficultyColor(quiz.difficulty),
                          ),
                        ),
                        backgroundColor: _getDifficultyBackgroundColor(quiz.difficulty),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du Quiz',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Catégorie', quiz.category),
            _buildInfoRow('Niveau de difficulté', _getDifficultyLabel(quiz.difficulty)),
            _buildInfoRow('Durée estimée', quiz.estimatedTime),
            _buildInfoRow('Nombre de questions', '${quiz.questionCount} questions'),
            _buildInfoRow('ID du quiz', quiz.id),
            _buildInfoRow(
              'Date de création', 
              DateFormat('dd/MM/yyyy à HH:mm').format(quiz.createdAt)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStatistics() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.people,
                  'Participants',
                  '${quiz.participants}',
                  Colors.blue,
                ),
                _buildStatItem(
                  Icons.star,
                  'Note moyenne',
                  quiz.rating > 0 ? '${quiz.rating}/5' : 'Aucune',
                  Colors.amber,
                ),
                _buildStatItem(
                  Icons.timer,
                  'Durée',
                  quiz.estimatedTime,
                  Colors.green,
                ),
              ],
            ),
            if (quiz.bestScore != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow('Meilleur score', '${quiz.bestScore}%'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${quiz.questionCount} questions'),
                  backgroundColor: Colors.blue.shade50,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (quiz.questions.isEmpty)
              _buildEmptyQuestions()
            else
              _buildQuestionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQuestions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'Aucune question pour le moment',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez des questions pour rendre ce quiz interactif',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
  return Column(
    children: quiz.questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${question.text}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (question.reponses.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: question.reponses.map((reponse) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: reponse.check ? Colors.green : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reponse.body,
                            style: TextStyle(
                              color: reponse.check ? Colors.green : Colors.grey[700],
                              fontWeight: reponse.check ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'Aucune option disponible',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      );
    }).toList(),
  );
}

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _startQuiz(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Commencer le Quiz'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _editQuiz(context),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _startQuiz(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Démarrage du quiz: ${quiz.title}'),
        backgroundColor: Colors.green,
      ),
    );
    // Ici vous pouvez naviguer vers l'écran de jeu du quiz
  }

  void _editQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizEditScreen(quiz: quiz),
      ),
    );
  }

  void _shareQuiz(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lien de partage copié dans le presse-papier'),
        backgroundColor: Colors.blue,
      ),
    );
    // Ici vous pouvez implémenter le partage du quiz
  }

  // Méthodes utilitaires (à réutiliser depuis votre écran principal)
  String _getDifficultyLabel(String difficulty) {
    final quizDifficulty = QuizzDifficulty.parse(difficulty);
    return quizDifficulty.label.toUpperCase();
  }

  Color _getDifficultyColor(String difficulty) {
    final quizDifficulty = QuizzDifficulty.parse(difficulty);
    switch (quizDifficulty) {
      case QuizzDifficulty.all:
        return Colors.grey[800]!;
      case QuizzDifficulty.beginner:
        return Colors.green;
      case QuizzDifficulty.intermediate:
        return Colors.orange;
      case QuizzDifficulty.advanced:
        return Colors.red;
      case QuizzDifficulty.expert:
        return Colors.purple;
    }
  }

  Color _getDifficultyBackgroundColor(String difficulty) {
    final quizDifficulty = QuizzDifficulty.parse(difficulty);
    switch (quizDifficulty) {
      case QuizzDifficulty.all:
        return Colors.grey.shade50;
      case QuizzDifficulty.beginner:
        return Colors.green.shade50;
      case QuizzDifficulty.intermediate:
        return Colors.orange.shade50;
      case QuizzDifficulty.advanced:
        return Colors.red.shade50;
      case QuizzDifficulty.expert:
        return Colors.purple.shade50;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'published':
        return 'PUBLIÉ';
      case 'draft':
        return 'BROUILLON';
      case 'archived':
        return 'ARCHIVÉ';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.blue;
      case 'archived':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'published':
        return Colors.green.shade50;
      case 'draft':
        return Colors.blue.shade50;
      case 'archived':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade50;
    }
  }
}
 