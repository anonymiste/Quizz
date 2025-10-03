import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/providers/admin.dart';

class AdminQuizzesScreen extends StatefulWidget {
  const AdminQuizzesScreen({super.key});

  @override
  State<AdminQuizzesScreen> createState() => _AdminQuizzesScreenState();
}

class _AdminQuizzesScreenState extends State<AdminQuizzesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _initialLoadComplete = false;
  DateTime? _lastUpdate;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _searchController.addListener(_onSearchChanged);
    _initializeQuizzes();
  }

  void _initializeQuizzes() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      await _loadQuizzes();

      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
          _lastUpdate = DateTime.now();
        });

        adminProvider.startQuizzesAutoRefresh();
      }
    });
  }

  Future<void> _loadQuizzes() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.loadQuizzes(
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }

  void _onSearchChanged() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _loadQuizzes();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.stopQuizzesAutoRefresh();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Gestion des Quiz'),
      //   backgroundColor: Colors.red,
      //   foregroundColor: Colors.white,
      //   actions: [
      //     IconButton(icon: const Icon(Icons.refresh), onPressed: _loadQuizzes),
      //     _buildLastUpdateIcon(),
      //   ],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadQuizzes,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: Icon(Icons.refresh),
        tooltip: 'Actualiser manuellement',
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.quizzes.isNotEmpty) {
                  _lastUpdate = DateTime.now();
                }

                if (!_initialLoadComplete && adminProvider.quizzes.isEmpty) {
                  return _buildLoading();
                }

                if (adminProvider.hasError) {
                  return _buildError(adminProvider);
                }

                if (adminProvider.quizzes.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildQuizzesList(adminProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un quiz...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadQuizzes();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
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
          Text('Chargement des quiz...'),
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
          Text(provider.errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadQuizzes,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun quiz trouvé'),
        ],
      ),
    );
  }

  Widget _buildQuizzesList(AdminProvider adminProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adminProvider.quizzes.length,
      itemBuilder: (context, index) =>
          _buildQuizCard(adminProvider.quizzes[index]),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final questions = quiz['questions'] as List? ?? [];
    final user = quiz['user'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quiz['title']?.toString() ?? 'Sans titre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text('${questions.length} questions'),
                  backgroundColor: Colors.red.shade100,
                ),
              ],
            ),
            if (quiz['description'] != null) ...[
              const SizedBox(height: 8),
              Text(
                quiz['description']!.toString(),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    quiz['difficulty']?.toString().toUpperCase() ?? 'DEBUTANT',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: _getDifficultyColor(quiz['difficulty']),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    quiz['category']?.toString().toUpperCase() ?? 'GENERAL',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Créé par: ${user?['name'] ?? 'Inconnu'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Participants: ${quiz['participants'] ?? 0}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Créé le: ${_formatDate(quiz['created_at'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (quiz['rating'] != null)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        quiz['rating'].toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // CORRECTION : Remplacer Tooltip par GestureDetector
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

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'expert':
        return Colors.red;
      case 'advanced':
        return Colors.orange;
      case 'intermediate':
        return Colors.blue;
      case 'beginner':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date invalide';
    }
  }
}
