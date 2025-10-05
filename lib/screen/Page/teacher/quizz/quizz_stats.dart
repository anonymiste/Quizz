import 'package:flutter/material.dart';
import 'package:quizz_interface/models/quizz.dart';

class QuizStatisticsDialog extends StatelessWidget {
  final Quizz quiz;
  final Map<String, dynamic> statistics;

  const QuizStatisticsDialog({
    super.key,
    required this.quiz,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Statistiques: ${quiz.title}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatCard(
              'Participants',
              '${statistics['total_participants'] ?? 0}',
            ),
            _buildStatCard(
              'Moyenne générale',
              '${statistics['average_score']?.toStringAsFixed(1) ?? '0'}/20',
            ),
            _buildStatCard(
              'Taux de réussite',
              '${statistics['success_rate']?.toStringAsFixed(1) ?? '0'}%',
            ),
            _buildStatCard(
              'Temps moyen',
              '${statistics['average_time']?.toStringAsFixed(0) ?? '0'} min',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
