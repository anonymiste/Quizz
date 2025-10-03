import 'package:flutter/material.dart';

class TeacherStatsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const TeacherStatsScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques Enseignant'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard('Vos statistiques', [
              _buildStatItem('Quiz créés', '23'),
              _buildStatItem('Étudiants actifs', '156'),
              _buildStatItem('Score moyen classe', '78%'),
              _buildStatItem('Participation', '92%'),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard('Performance des étudiants', [
              _buildStatItem('Meilleur score', '95%'),
              _buildStatItem('Score moyen', '78%'),
              _buildStatItem('Plus faible', '45%'),
              _buildStatItem('Complétion', '88%'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}