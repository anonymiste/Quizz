import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/providers/quizz.dart';

class QuizzListScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const QuizzListScreen({super.key, required this.userData});

  @override
  State<QuizzListScreen> createState() => _QuizzListScreenState();
}

class _QuizzListScreenState extends State<QuizzListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizzes();
    });
  }

  void _loadQuizzes() {
    final quizProvider = Provider.of<QuizzProvider>(context, listen: false);
    quizProvider.loadQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Quiz'),
        backgroundColor: const Color.fromARGB(255, 74, 111, 165),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
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
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: Consumer<QuizzProvider>(
              builder: (context, quizProvider, child) {
                if (quizProvider.isLoading) {
                  return _buildLoadingState();
                }

                if (quizProvider.hasError) {
                  return _buildErrorWidget(quizProvider.errorMessage, quizProvider);
                }

                final quizzes = quizProvider.quizzes.where((quiz) =>
                    quiz.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                if (quizzes.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) => _buildQuizCard(quizzes[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewQuiz,
        backgroundColor: const Color.fromARGB(255, 74, 111, 165),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuizCard(dynamic quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.quiz, color: Color.fromARGB(255, 74, 111, 165)),
        title: Text(quiz.title ?? 'Quiz sans titre'),
        subtitle: Text(quiz.description ?? 'Aucune description'),
        trailing: Chip(
          label: Text('${quiz.questions.length} questions'),
          backgroundColor: const Color.fromARGB(255, 74, 111, 165),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        onTap: () => _startQuiz(quiz),
      ),
    );
  }

  Widget _buildLoadingState() {
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

  Widget _buildErrorWidget(String error, QuizzProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Erreur de chargement', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                _loadQuizzes();
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
          const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Aucun quiz trouvé', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          const Text('Essayez de modifier votre recherche'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _createNewQuiz,
            child: const Text('Créer un quiz'),
          ),
        ],
      ),
    );
  }

  void _startQuiz(dynamic quiz) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Démarrage: ${quiz.title}')),
    );
  }

  void _createNewQuiz() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création d\'un nouveau quiz')),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}