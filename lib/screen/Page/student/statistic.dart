import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/providers/statistics.dart';

class StatisticsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const StatisticsScreen({super.key, required this.userData});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      statisticsProvider.loadUserStatistics(userData: widget.userData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 255),
      body: Consumer<StatisticsProvider>(
        builder: (context, statisticsProvider, child) {
          if (statisticsProvider.isLoading) {
            return _buildLoadingIndicator();
          }

          if (statisticsProvider.hasError) {
            return _buildErrorWidget(statisticsProvider.errorMessage, statisticsProvider);
          }

          if (!statisticsProvider.hasStatistics) {
            return _buildEmptyState();
          }

          return _buildStatisticsContent(statisticsProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStatistics,
        tooltip: 'Actualiser',
        backgroundColor: const Color.fromARGB(255, 74, 111, 165),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Chargement des statistiques...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage, StatisticsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                _loadStatistics();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Aucune statistique disponible',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text('Commencez par compléter quelques quiz !'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadStatistics,
            child: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(StatisticsProvider provider) {
    final statistics = provider.userStatistics!;
    
    return RefreshIndicator(
      onRefresh: () async => _loadStatistics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserHeader(statistics),
            const SizedBox(height: 20),
            _buildStatsGrid(statistics),
            const SizedBox(height: 20),
            _buildRecentActivity(statistics),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(dynamic statistics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color.fromARGB(255, 74, 111, 165),
              child: Text(
                widget.userData['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userData['name']?.toString() ?? 'Utilisateur',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.userData['email']?.toString() ?? ''),
                  Chip(
                    label: Text(widget.userData['role']?.toString().toUpperCase() ?? 'USER'),
                    backgroundColor: const Color.fromARGB(255, 74, 111, 165),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(dynamic statistics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildStatCard('Points', '${statistics.statistics?.totalPoints ?? 0}', Icons.emoji_events),
        _buildStatCard('Quiz complétés', '${statistics.statistics?.quizzesCompleted ?? 0}', Icons.quiz),
        _buildStatCard('Taux de réussite', '${statistics.statistics?.successRate?.toStringAsFixed(1) ?? 0}%', Icons.trending_up),
        _buildStatCard('Réponses correctes', '${statistics.statistics?.correctAnswers ?? 0}', Icons.check_circle),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color.fromARGB(255, 74, 111, 165)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(dynamic statistics) {
    final activities = statistics.recentActivity ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activité récente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (activities.isEmpty)
              const Text('Aucune activité récente')
            else
              ...activities.map((activity) => ListTile(
                    leading: const Icon(Icons.quiz),
                    title: Text(activity.quiz ?? 'Quiz'),
                    subtitle: Text('Score: ${activity.score ?? 0}%'),
                    trailing: Text(activity.date ?? ''),
                  )),
          ],
        ),
      ),
    );
  }
}