import 'package:flutter/material.dart';
import 'package:quizz_interface/models/cours.dart';

class CourseStatisticsDialog extends StatelessWidget {
  final Course course;
  final Map<String, dynamic> statistics;

  const CourseStatisticsDialog({
    super.key,
    required this.course,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final courseStats = statistics['course'] ?? {};
    final themesProgress = statistics['themes_progress'] ?? [];

    return AlertDialog(
      title: Text('Statistiques: ${course.title}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatCard(
              'Thèmes total',
              '${courseStats['total_themes'] ?? 0}',
            ),
            _buildStatCard(
              'Questions total',
              '${courseStats['total_questions'] ?? 0}',
            ),
            _buildStatCard(
              'Moyenne générale',
              '${courseStats['average_score']?.toStringAsFixed(1) ?? '0'}',
            ),

            if (themesProgress.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Progression par thème:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...themesProgress.map<Widget>((theme) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      '${theme['score'] ?? 0}',
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),
                  title: Text(theme['title'] ?? ''),
                  subtitle: Text('${theme['questions_count'] ?? 0} questions'),
                );
              }).toList(),
            ],
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
 