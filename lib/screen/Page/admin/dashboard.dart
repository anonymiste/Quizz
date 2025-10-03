import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/providers/admin.dart';
import 'package:quizz_interface/screen/Page/admin/quizzes_management.dart';
import 'package:quizz_interface/screen/Page/admin/users_management.dart';
import 'package:quizz_interface/screen/Page/setting.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _initialLoadComplete = false;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  void _initializeDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      // Chargement initial
      await _loadData();

      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
          _lastUpdate = DateTime.now();
        });

        // Démarrer l'auto-reload
        adminProvider.startAutoRefresh();
      }
    });
  }

  Future<void> _loadData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.loadDashboardStats();
    await adminProvider.loadSystemAnalytics();
  }

  @override
  void dispose() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.stopAutoRefresh();
    super.dispose();
  }

  String _safeParseStat(dynamic value) {
    if (value == null) return '0';
    if (value is int) return value.toString();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed?.toString() ?? '0';
    }
    if (value is double) return value.toInt().toString();
    return '0';
  }

  String _safeParsePercentage(dynamic value) {
    if (value == null) return '0.0';
    if (value is double) return value.toStringAsFixed(1);
    if (value is int) return value.toDouble().toStringAsFixed(1);
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toStringAsFixed(1) ?? '0.0';
    }
    return '0.0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: Icon(Icons.refresh),
        tooltip: 'Actualiser manuellement',
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          // Mettre à jour la date à chaque reconstruction
          if (adminProvider.dashboardStats.isNotEmpty) {
            _lastUpdate = DateTime.now();
          }

          if (!_initialLoadComplete && adminProvider.dashboardStats.isEmpty) {
            return _buildLoading();
          }

          if (adminProvider.hasError) {
            return _buildError(adminProvider);
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 20),
                  _buildStatsGrid(adminProvider.dashboardStats),
                  const SizedBox(height: 20),
                  _buildAnalyticsSection(adminProvider.systemAnalytics),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  _buildLastUpdate(),
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
          Text('Chargement du dashboard...'),
        ],
      ),
    );
  }

  Widget _buildError(AdminProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(provider.errorMessage),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loadData, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade700, Colors.red.shade900],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, size: 32, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Dashboard Administrateur',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Gestion complète de la plateforme Quizz - Mise à jour automatique',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    final statItems = [
      _StatItem(
        'Utilisateurs',
        _safeParseStat(stats['total_users']),
        Icons.people,
        Colors.blue,
      ),
      _StatItem(
        'Enseignants',
        _safeParseStat(stats['total_teachers']),
        Icons.school,
        Colors.green,
      ),
      _StatItem(
        'Étudiants',
        _safeParseStat(stats['total_students']),
        Icons.person,
        Colors.orange,
      ),
      _StatItem(
        'Quiz',
        _safeParseStat(stats['total_quizzes']),
        Icons.quiz,
        Colors.purple,
      ),
      _StatItem(
        'Phases',
        _safeParseStat(stats['total_phases']),
        Icons.flag,
        Colors.teal,
      ),
      _StatItem(
        'En ligne',
        _safeParseStat(stats['online_users']),
        Icons.wifi,
        Colors.green,
      ),
      _StatItem(
        'Tentatives',
        _safeParseStat(stats['total_quiz_attempts']),
        Icons.assignment,
        Colors.indigo,
      ),
      _StatItem(
        'Points totaux',
        _safeParseStat(stats['total_points_distributed']),
        Icons.emoji_events,
        Colors.amber,
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statItems.length,
      itemBuilder: (context, index) => _buildStatCard(statItems[index]),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 32, color: item.color),
            const SizedBox(height: 8),
            Text(
              item.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(Map<String, dynamic> analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Analytics Système',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsItem(
              'Utilisateurs aujourd\'hui',
              _safeParseStat(analytics['users_growth']?['today']),
            ),
            _buildAnalyticsItem(
              'Utilisateurs cette semaine',
              _safeParseStat(analytics['users_growth']?['this_week']),
            ),
            _buildAnalyticsItem(
              'Quiz créés aujourd\'hui',
              _safeParseStat(analytics['quizzes_analytics']?['quizzes_today']),
            ),
            _buildAnalyticsItem(
              'Taux de réussite moyen',
              '${_safeParsePercentage(analytics['performance_metrics']?['average_success_rate'])}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value) {
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

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Actions Rapides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton('Gérer les utilisateurs', Icons.people, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UsersManagementScreen(),
                    ),
                  );
                }),
                _buildActionButton('Gérer les quiz', Icons.quiz, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminQuizzesScreen(),
                    ),
                  );
                }),
                _buildActionButton('Statistiques', Icons.bar_chart, () {
                  // Naviguer vers les stats si vous avez un écran dédié
                }),
                _buildActionButton('Paramètres', Icons.settings, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildLastUpdate() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.autorenew, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            _lastUpdate != null
                ? 'Dernière mise à jour: ${_lastUpdate!.hour}:${_lastUpdate!.minute.toString().padLeft(2, '0')}:${_lastUpdate!.second.toString().padLeft(2, '0')}'
                : 'Chargement...',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem(this.label, this.value, this.icon, this.color);
}
