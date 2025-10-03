import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/providers/admin.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _initializeStats();
  }

  void _initializeStats() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      await _loadStats();

      if (mounted) {
        setState(() {
          _lastUpdate = DateTime.now();
        });

        adminProvider.startStatsAutoRefresh();
      }
    });
  }

  Future<void> _loadStats() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.loadSystemAnalytics();
  }

  @override
  void dispose() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.stopStatsAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Statistiques Détaillées'),
      //   backgroundColor: Colors.red,
      //   foregroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh),
      //       onPressed: _loadStats,
      //       tooltip: 'Actualiser',
      //     ),
      //     _buildLastUpdateIcon(),
      //   ],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStats,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: Icon(Icons.refresh),
        tooltip: 'Actualiser manuellement',
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.systemAnalytics.isNotEmpty) {
            _lastUpdate = DateTime.now();
          }

          if (adminProvider.isLoading &&
              adminProvider.systemAnalytics.isEmpty) {
            return _buildLoading();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadStats(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildGrowthStats(adminProvider.systemAnalytics),
                  const SizedBox(height: 20),
                  _buildPerformanceStats(adminProvider.systemAnalytics),
                  const SizedBox(height: 20),
                  _buildRecentActivity(adminProvider.systemAnalytics),
                  _buildLastUpdateFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des statistiques...'),
        ],
      ),
    );
  }

  Widget _buildGrowthStats(Map<String, dynamic> analytics) {
    final growth = analytics['users_growth'] ?? {};
    final quizzes = analytics['quizzes_analytics'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Croissance de la Plateforme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Utilisateurs aujourd\'hui',
              growth['today']?.toString() ?? '0',
              Icons.person_add,
            ),
            _buildStatRow(
              'Utilisateurs cette semaine',
              growth['this_week']?.toString() ?? '0',
              Icons.people,
            ),
            _buildStatRow(
              'Utilisateurs ce mois',
              growth['this_month']?.toString() ?? '0',
              Icons.group,
            ),
            _buildStatRow(
              'Total utilisateurs',
              growth['total']?.toString() ?? '0',
              Icons.person,
            ),
            const Divider(),
            _buildStatRow(
              'Quiz créés aujourd\'hui',
              quizzes['quizzes_today']?.toString() ?? '0',
              Icons.quiz,
            ),
            _buildStatRow(
              'Questions moyennes par quiz',
              quizzes['average_questions_per_quiz']?.toStringAsFixed(1) ?? '0',
              Icons.question_answer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStats(Map<String, dynamic> analytics) {
    final performance = analytics['performance_metrics'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Performance Globale',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Taux de réussite moyen',
              '${performance['average_success_rate']?.toStringAsFixed(1) ?? '0'}%',
              Icons.star,
            ),
            _buildStatRow(
              'Tentatives totales',
              performance['total_quiz_attempts']?.toString() ?? '0',
              Icons.assignment,
            ),
            _buildStatRow(
              'Temps moyen par quiz',
              '${performance['average_time_per_quiz']?.toStringAsFixed(0) ?? '0'} min',
              Icons.timer,
            ),
            _buildStatRow(
              'Taux de complétion',
              '${performance['completion_rate']?.toStringAsFixed(1) ?? '0'}%',
              Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(Map<String, dynamic> analytics) {
    final activity = analytics['recent_activity'] ?? {};
    final recentUsers = activity['recent_users'] as List? ?? [];
    final recentQuizzes = activity['recent_quizzes'] as List? ?? [];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Activité Récente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (recentUsers.isNotEmpty) ...[
              const Text(
                'Nouveaux Utilisateurs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...recentUsers
                  .map((user) => _buildUserActivityItem(user))
                  .toList(),
              const SizedBox(height: 16),
            ],

            if (recentQuizzes.isNotEmpty) ...[
              const Text(
                'Quiz Récemment Créés',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...recentQuizzes
                  .map((quiz) => _buildQuizActivityItem(quiz))
                  .toList(),
            ],

            if (recentUsers.isEmpty && recentQuizzes.isEmpty) ...[
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Aucune activité récente'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivityItem(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            user['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
          ),
        ),
        title: Text(
          user['name']?.toString() ?? 'Utilisateur',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${user['points'] ?? 0} points • ${user['role'] ?? 'user'}',
        ),
        trailing: Text(
          _formatDate(user['joined_at']),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildQuizActivityItem(Map<String, dynamic> quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: const Icon(Icons.quiz, color: Colors.purple),
        title: Text(
          quiz['title']?.toString() ?? 'Quiz',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${quiz['questions_count'] ?? 0} questions • ${quiz['creator'] ?? 'Inconnu'}',
        ),
        trailing: Text(
          _formatDate(quiz['created_at']),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildLastUpdateIcon() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _lastUpdate != null
                  ? 'Dernière MAJ: ${_lastUpdate!.hour}:${_lastUpdate!.minute.toString().padLeft(2, '0')}'
                  : 'Chargement...',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(Icons.autorenew, color: Colors.green, size: 20),
      ),
    );
  }

  Widget _buildLastUpdateFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.autorenew, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            _lastUpdate != null
                ? 'Statistiques mises à jour à ${_lastUpdate!.hour}:${_lastUpdate!.minute.toString().padLeft(2, '0')}:${_lastUpdate!.second.toString().padLeft(2, '0')}'
                : 'Chargement...',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Date inconnue';
    try {
      final dateString = date.toString();
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}';
    } catch (e) {
      return 'Date invalide';
    }
  }
}
