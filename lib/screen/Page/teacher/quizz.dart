import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/enums/quizz_dificulty.dart';
import 'package:quizz_interface/enums/quizz_tech_cat%C3%A9gory.dart';
import 'package:quizz_interface/models/questions.dart';
import 'package:quizz_interface/models/quizz.dart';
import 'package:quizz_interface/models/reponse.dart';
import 'package:quizz_interface/providers/teacher.dart';

class TeacherQuizzesScreen extends StatefulWidget {
  const TeacherQuizzesScreen({super.key});

  @override
  State<TeacherQuizzesScreen> createState() => _TeacherQuizzesScreenState();
}

class _TeacherQuizzesScreenState extends State<TeacherQuizzesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizzes();
    });
  }

  void _loadQuizzes() {
    final teacherProvider = Provider.of<TeacherProvider>(
      context,
      listen: false,
    );

    teacherProvider.refreshQuizzes();
    _isInitialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadQuizzes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Créés'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewQuiz,
            tooltip: 'Créer un nouveau quiz',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuizzes,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          // Vérifier si l'utilisateur est un teacher
          if (!teacherProvider.isTeacher) {
            return _buildNotTeacherState();
          }

          return Column(
            children: [
              // Barre de recherche et filtres
              _buildSearchAndFilters(),
              const SizedBox(height: 8),

              // Liste des quiz
              Expanded(child: _buildQuizList(teacherProvider)),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (!teacherProvider.isTeacher) return const SizedBox();

          return FloatingActionButton(
            onPressed: _createNewQuiz,
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            heroTag: 'teacher_quizzes_fab',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildNotTeacherState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Accès réservé aux enseignants',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Cette fonctionnalité n\'est disponible que pour les enseignants',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          // Barre de recherche - Prend l'espace disponible
          Expanded(
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
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12), // Utiliser width au lieu de height
          // Filtre dropdown - Prend l'espace nécessaire
          Container(
            width: 180,
            child: DropdownButtonFormField<QuizzDifficulty>(
              value: QuizzDifficulty.parse(_selectedFilter),
              decoration: InputDecoration(
                labelText: 'Niveau de difficulté',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: QuizzDifficulty.values.map((difficulty) {
                return DropdownMenuItem<QuizzDifficulty>(
                  value: difficulty,
                  child: Row(
                    children: [
                      _getDifficultyIcon(
                        difficulty.name,
                      ), // Convertir enum en string
                      const SizedBox(width: 12),
                      Text(
                        difficulty.label,
                        style: TextStyle(
                          color: _getDifficultyColor(
                            difficulty.name,
                          ), // Convertir enum en string
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value.name;
                  });
                }
              },
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              isExpanded: true,
            ),
          ),
          // Container(
          //   width: 180,
          //   child: DropdownButtonFormField<QuizzDifficulty>(
          //     value: QuizzDifficulty.parse(_selectedFilter),
          //     decoration: InputDecoration(
          //       labelText: 'Filtrer par niveau',
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       contentPadding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 12,
          //       ),
          //       filled: true,
          //       fillColor: Colors.white,
          //     ),
          //     items: QuizzDifficulty.values.map((difficulty) {
          //       return DropdownMenuItem<QuizzDifficulty>(
          //         value: difficulty,
          //         child: Row(
          //           children: [
          //             _getDifficultyIcon(difficulty.toString()),
          //             const SizedBox(width: 12),
          //             Text(
          //               difficulty.label,
          //               style: TextStyle(
          //                 color: _getDifficultyColor(difficulty.toString()),
          //               ),
          //             ),
          //           ],
          //         ),
          //       );
          //     }).toList(),
          //     onChanged: (value) {
          //       if (value != null) {
          //         setState(() {
          //           _selectedFilter = value.name;
          //         });
          //       }
          //     },
          //     style: TextStyle(color: Colors.grey[800], fontSize: 14),
          //     dropdownColor: Colors.white,
          //     icon: const Icon(Icons.arrow_drop_down),
          //     iconSize: 24,
          //     isExpanded: true,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildQuizList(TeacherProvider teacherProvider) {
    if (teacherProvider.isLoadingQuizzes) {
      return _buildLoading();
    }

    if (teacherProvider.quizzesError.isNotEmpty) {
      return _buildErrorState(teacherProvider);
    }

    if (teacherProvider.quizzes.isEmpty) {
      return _buildEmptyState();
    }

    final filteredQuizzes = _filterQuizzes(teacherProvider.quizzes);

    if (filteredQuizzes.isEmpty) {
      return _buildNoResultsState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadQuizzes(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredQuizzes.length,
        itemBuilder: (context, index) =>
            _buildQuizCard(filteredQuizzes[index], teacherProvider),
      ),
    );
  }

  Widget _buildQuizCard(Quizz quiz, TeacherProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.quiz, color: Colors.orange, size: 30),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.description.length > 60
                  ? '${quiz.description.substring(0, 60)}...'
                  : quiz.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(
                    '${quiz.questionCount} questions',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.blue.shade50,
                ),
                Chip(
                  label: Text(
                    quiz.estimatedTime,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.green.shade50,
                ),
                Chip(
                  label: Text(
                    _getDifficultyLabel(quiz.difficulty),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getDifficultyColor(quiz.difficulty),
                    ),
                  ),
                  backgroundColor: _getDifficultyBackgroundColor(
                    quiz.difficulty,
                  ),
                ),
                Chip(
                  label: Text(
                    '${quiz.participants} participants',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.purple.shade50,
                ),
                if (quiz.rating > 0)
                  Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          quiz.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.amber.shade50,
                  ),
                // Statut du quiz
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
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'edit',
              child: const ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Modifier'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'preview',
              child: const ListTile(
                leading: Icon(Icons.visibility, color: Colors.purple),
                title: Text('Prévisualiser'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'stats',
              child: const ListTile(
                leading: Icon(Icons.analytics, color: Colors.green),
                title: Text('Statistiques'),
              ),
            ),
            if (quiz.status != 'published')
              PopupMenuItem<String>(
                value: 'publish',
                child: ListTile(
                  leading: Icon(Icons.public, color: Colors.green[700]),
                  title: const Text('Publier'),
                ),
              ),
            if (quiz.status == 'published')
              PopupMenuItem<String>(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.archive, color: Colors.orange[700]),
                  title: const Text('Archiver'),
                ),
              ),
            PopupMenuItem<String>(
              value: 'duplicate',
              child: const ListTile(
                leading: Icon(Icons.copy, color: Colors.orange),
                title: Text('Dupliquer'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: const ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Supprimer'),
              ),
            ),
          ],
          onSelected: (value) => _handleQuizAction(value, quiz, provider),
        ),
        onTap: () => _viewQuizDetails(quiz),
      ),
    );
  }

  String _getDifficultyLabel(String difficulty) {
    final quizDifficulty = QuizzDifficulty.parse(difficulty);
    return quizDifficulty.label.toUpperCase();
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

  Widget _buildErrorState(TeacherProvider teacherProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, color: Colors.red.shade700),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              teacherProvider.quizzesError,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadQuizzes,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Aucun quiz créé',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Commencez par créer votre premier quiz',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _createNewQuiz,
            icon: const Icon(Icons.add),
            label: const Text('Créer un quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Aucun résultat trouvé',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _createNewQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizCreationScreen()),
    );
  }

  void _viewQuizDetails(Quizz quiz) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuizQuestionsScreen(quiz: quiz),
    ),
  );
}

  void _handleQuizAction(String action, Quizz quiz, TeacherProvider provider) {
    switch (action) {
      case 'edit':
        _editQuiz(quiz);
        break;
      case 'preview':
        _previewQuiz(quiz);
        break;
      case 'stats':
        _viewQuizStats(quiz, provider);
        break;
      case 'publish':
        _publishQuiz(quiz, provider);
        break;
      case 'archive':
        _archiveQuiz(quiz, provider);
        break;
      case 'duplicate':
        _duplicateQuiz(quiz, provider);
        break;
      case 'delete':
        _deleteQuiz(quiz, provider);
        break;
    }
  }

  Widget _getDifficultyIcon(String difficulty) {
    final quizDifficulty = QuizzDifficulty.parse(difficulty);
    switch (quizDifficulty) {
      case QuizzDifficulty.all:
        return Icon(Icons.all_inclusive, color: Colors.grey[600], size: 20);
      case QuizzDifficulty.beginner:
        return Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
          size: 20,
        );
      case QuizzDifficulty.intermediate:
        return Icon(Icons.sentiment_satisfied, color: Colors.orange, size: 20);
      case QuizzDifficulty.advanced:
        return Icon(Icons.sentiment_neutral, color: Colors.red, size: 20);
      case QuizzDifficulty.expert:
        return Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.purple,
          size: 20,
        );
    }
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

  List<Quizz> _filterQuizzes(List<Quizz> quizzes) {
    var filtered = quizzes;

    // Filtre par difficulté en utilisant l'enum
    if (_selectedFilter != 'all') {
      final selectedDifficulty = QuizzDifficulty.parse(_selectedFilter);
      filtered = filtered.where((quiz) {
        final quizDifficulty = QuizzDifficulty.parse(quiz.difficulty);
        return quizDifficulty == selectedDifficulty;
      }).toList();
    }

    // Filtre par recherche
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (quiz) =>
                quiz.title.toLowerCase().contains(searchLower) ||
                quiz.description.toLowerCase().contains(searchLower) ||
                quiz.category.toLowerCase().contains(searchLower),
          )
          .toList();
    }

    return filtered;
  }

  void _editQuiz(Quizz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizEditScreen(quiz: quiz)),
    );
  }

  void _previewQuiz(Quizz quiz) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuizDetailScreen(quiz: quiz),
    ),
  );
}



  void _viewQuizStats(Quizz quiz, TeacherProvider provider) async {
    final statistics = await provider.getQuizStatistics(
      int.tryParse(quiz.id) ?? 0,
    );
    if (statistics != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) =>
            QuizStatisticsDialog(quiz: quiz, statistics: statistics),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${provider.quizzesError}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _publishQuiz(Quizz quiz, TeacherProvider provider) async {
    final success = await provider.publishQuiz(int.tryParse(quiz.id) ?? 0);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz "${quiz.title}" publié'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${provider.quizzesError}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _archiveQuiz(Quizz quiz, TeacherProvider provider) async {
    final success = await provider.archiveQuiz(int.tryParse(quiz.id) ?? 0);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz "${quiz.title}" archivé'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${provider.quizzesError}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _duplicateQuiz(Quizz quiz, TeacherProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dupliquer le quiz'),
        content: Text(
          'Êtes-vous sûr de vouloir dupliquer le quiz "${quiz.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.duplicateQuiz(
                int.tryParse(quiz.id) ?? 0,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Quiz "${quiz.title}" dupliqué'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${provider.quizzesError}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Dupliquer'),
          ),
        ],
      ),
    );
  }

  void _deleteQuiz(Quizz quiz, TeacherProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le quiz'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le quiz "${quiz.title}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteQuiz(
                int.tryParse(quiz.id) ?? 0,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Quiz "${quiz.title}" supprimé'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${provider.quizzesError}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// Écrans de placeholder pour la création et édition
class QuizCreationScreen extends StatefulWidget {
  const QuizCreationScreen({super.key});

  @override
  State<QuizCreationScreen> createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends State<QuizCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedDifficulty = 'beginner';
  QuizzCategory _selectedCategory = QuizzCategory.programming;
  bool _isPublic = true;
  bool _isSubmitting = false;

  // Méthode pour obtenir l'icône Material à partir du nom
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case "code":
        return Icons.code;
      case "build":
        return Icons.build;
      case "security":
        return Icons.security;
      case "settings_ethernet":
        return Icons.settings_ethernet;
      case "storage":
        return Icons.storage;
      case "language":
        return Icons.language;
      case "smartphone":
        return Icons.smartphone;
      case "cloud":
        return Icons.cloud;
      case "smart_toy":
        return Icons.smart_toy;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _createQuiz() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final teacherProvider = Provider.of<TeacherProvider>(
          context,
          listen: false,
        );

        // Préparer les données du quiz
        final quizData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'difficulty': _selectedDifficulty,
          'category': _selectedCategory.value,
          'time_limit': int.tryParse(_durationController.text) ?? 30,
          'status': _isPublic ? 'published' : 'draft',
          'questions': [], // Liste vide pour commencer
        };

        print('🔄 Création du quiz: $quizData');

        // Appeler le provider pour créer le quiz
        final success = await teacherProvider.createQuiz(quizData);

        if (success) {
          // Afficher un message de succès
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Quiz "${_titleController.text}" créé avec succès!',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Naviguer en arrière
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Afficher l'erreur du provider
          if (mounted) {
            _showError(teacherProvider.quizzesError);
          }
        }
      } catch (e) {
        // Gérer les erreurs inattendues
        if (mounted) {
          _showError('Erreur inattendue: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Quiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _createQuiz,
              tooltip: 'Sauvegarder le quiz',
            ),
        ],
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicateur de chargement
                  if (teacherProvider.isCreatingQuiz) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Création du quiz en cours...',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Titre du quiz
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre du quiz *',
                      border: OutlineInputBorder(),
                      hintText: 'Entrez le titre du quiz',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un titre';
                      }
                      if (value.length < 3) {
                        return 'Le titre doit contenir au moins 3 caractères';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Description du quiz
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Description du quiz (optionnel)',
                    ),
                    maxLines: 3,
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Difficulté
                  DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Niveau de difficulté',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'beginner',
                        child: Text('Facile'),
                      ),
                      DropdownMenuItem(
                        value: 'intermediate',
                        child: Text('Intermédiaire'),
                      ),
                      DropdownMenuItem(
                        value: 'advanced',
                        child: Text('Difficile'),
                      ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedDifficulty = value!;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Catégorie avec l'enum QuizzCategory
                  DropdownButtonFormField<QuizzCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                    items: QuizzCategory.values.map((category) {
                      return DropdownMenuItem<QuizzCategory>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _getIconData(category.icon),
                              color: Color(category.materialColor),
                            ),
                            const SizedBox(width: 12),
                            Text(category.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),

                  // Durée
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Durée (minutes)',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 30',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Veuillez entrer un nombre valide';
                        }
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Visibilité
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visibilité',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Switch(
                                value: _isPublic,
                                onChanged: _isSubmitting
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _isPublic = value;
                                        });
                                      },
                                activeColor: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPublic ? 'Public' : 'Privé',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            _isPublic
                                ? 'Tout le monde peut voir et participer à ce quiz'
                                : 'Seulement les personnes avec le lien peuvent participer',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Affichage de la catégorie sélectionnée
                  Card(
                    color: Color(
                      _selectedCategory.materialColor,
                    ).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(_selectedCategory.icon),
                            color: Color(_selectedCategory.materialColor),
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedCategory.label,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                      _selectedCategory.materialColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  _selectedCategory.description,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Afficher les erreurs du provider
                  if (teacherProvider.hasQuizzesError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              teacherProvider.quizzesError,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red.shade700),
                            onPressed: () {
                              teacherProvider.clearQuizError();
                            },
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Bouton de création
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _createQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Création en cours...'),
                              ],
                            )
                          : const Text(
                              'Créer le Quiz',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuizEditScreen extends StatefulWidget {
  final Quizz quiz;

  const QuizEditScreen({super.key, required this.quiz});

  @override
  State<QuizEditScreen> createState() => _QuizEditScreenState();
}

class _QuizEditScreenState extends State<QuizEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedDifficulty = 'beginner';
  QuizzCategory _selectedCategory = QuizzCategory.programming;
  String _selectedStatus = 'draft';
  bool _isSubmitting = false;

  // Méthode pour obtenir l'icône Material à partir du nom
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case "code":
        return Icons.code;
      case "build":
        return Icons.build;
      case "security":
        return Icons.security;
      case "settings_ethernet":
        return Icons.settings_ethernet;
      case "storage":
        return Icons.storage;
      case "language":
        return Icons.language;
      case "smartphone":
        return Icons.smartphone;
      case "cloud":
        return Icons.cloud;
      case "smart_toy":
        return Icons.smart_toy;
      default:
        return Icons.category;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les données du quiz
    _titleController.text = widget.quiz.title;
    _descriptionController.text = widget.quiz.description;
    _durationController.text = widget.quiz.timeLimit.toString();
    _selectedDifficulty = widget.quiz.difficulty;
    _selectedCategory = QuizzCategory.values.firstWhere(
      (category) => category.value == widget.quiz.category,
      orElse: () => QuizzCategory.programming,
    );
    _selectedStatus = widget.quiz.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _updateQuiz() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final teacherProvider = Provider.of<TeacherProvider>(
          context,
          listen: false,
        );

        // Préparer les données de mise à jour (même format que la création)
        final quizData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'difficulty': _selectedDifficulty,
          'category': _selectedCategory.value,
          'time_limit': int.tryParse(_durationController.text) ?? 30,
          'status': _selectedStatus,
        };

        print('🔄 Mise à jour du quiz: $quizData');

        // Appeler le provider pour mettre à jour le quiz
        final success = await teacherProvider.updateQuiz(
          int.tryParse(widget.quiz.id) ?? 0,
          quizData,
        );

        if (success) {
          // Afficher un message de succès
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Quiz "${_titleController.text}" modifié avec succès!',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Naviguer en arrière
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Afficher l'erreur du provider
          if (mounted) {
            _showError(teacherProvider.quizzesError);
          }
        }
      } catch (e) {
        // Gérer les erreurs inattendues
        if (mounted) {
          _showError('Erreur inattendue: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le Quiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateQuiz,
              tooltip: 'Sauvegarder les modifications',
            ),
        ],
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicateur de chargement
                  if (teacherProvider.isUpdatingQuiz) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Mise à jour du quiz en cours...',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Informations du quiz existant
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quiz #${widget.quiz.id}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                Text(
                                  'Créé le ${DateFormat('dd/MM/yyyy').format(widget.quiz.createdAt)}',
                                  style: TextStyle(color: Colors.blue.shade600),
                                ),
                                Text(
                                  '${widget.quiz.participants} participants • ${widget.quiz.rating}/5 ⭐',
                                  style: TextStyle(color: Colors.blue.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Titre du quiz
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre du quiz *',
                      border: OutlineInputBorder(),
                      hintText: 'Entrez le titre du quiz',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un titre';
                      }
                      if (value.length < 3) {
                        return 'Le titre doit contenir au moins 3 caractères';
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Description du quiz
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Description du quiz (optionnel)',
                    ),
                    maxLines: 3,
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Difficulté
                  DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Niveau de difficulté',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'beginner',
                        child: Text('Facile'),
                      ),
                      DropdownMenuItem(
                        value: 'intermediate',
                        child: Text('Intermédiaire'),
                      ),
                      DropdownMenuItem(
                        value: 'advanced',
                        child: Text('Difficile'),
                      ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedDifficulty = value!;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Catégorie avec l'enum QuizzCategory
                  DropdownButtonFormField<QuizzCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                    items: QuizzCategory.values.map((category) {
                      return DropdownMenuItem<QuizzCategory>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _getIconData(category.icon),
                              color: Color(category.materialColor),
                            ),
                            const SizedBox(width: 12),
                            Text(category.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),

                  // Durée
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Durée (minutes)',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 30',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Veuillez entrer un nombre valide';
                        }
                      }
                      return null;
                    },
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 16),

                  // Statut du quiz
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Statut du quiz',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'draft',
                        child: Text('Brouillon'),
                      ),
                      DropdownMenuItem(
                        value: 'published',
                        child: Text('Publié'),
                      ),
                      DropdownMenuItem(
                        value: 'archived',
                        child: Text('Archivé'),
                      ),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 16),

                  // Affichage de la catégorie sélectionnée
                  Card(
                    color: Color(
                      _selectedCategory.materialColor,
                    ).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(_selectedCategory.icon),
                            color: Color(_selectedCategory.materialColor),
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedCategory.label,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                      _selectedCategory.materialColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  _selectedCategory.description,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Afficher les erreurs du provider
                  if (teacherProvider.hasQuizzesError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              teacherProvider.quizzesError,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red.shade700),
                            onPressed: () {
                              teacherProvider.clearQuizError();
                            },
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _updateQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isSubmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Mise à jour...'),
                                  ],
                                )
                              : const Text(
                                  'Sauvegarder',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

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
    return _questions.fold(0, (sum, question) => sum + (question.points ?? 1));
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
                final optIndex = entry.key;
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
                  label: Text('${question.points ?? 1} pt${question.points != 1 ? 's' : ''}'),
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

class QuestionEditDialog extends StatefulWidget {
  final Quizz quizz;
  final Question? question;
  final int? questionIndex;
  final Function(Question) onQuestionSaved;

  const QuestionEditDialog({
    super.key,
    required this.quizz,
    this.question,
    this.questionIndex,
    required this.onQuestionSaved,
  });

  @override
  State<QuestionEditDialog> createState() => _QuestionEditDialogState();
}

class _QuestionEditDialogState extends State<QuestionEditDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs
  final TextEditingController _quizzIdController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController(text: '1');
  final TextEditingController _timeLimitController = TextEditingController(text: '30');
  final TextEditingController _orderController = TextEditingController(text: '1');
  final TextEditingController _correctAnswerIndexController = TextEditingController(text: '0');
  final TextEditingController _codeSnippetController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  
  // Variables d'état
  String _type = 'multiple_choice';
  int _correctAnswerIndex = 0;
  List<String> _options = ['', '']; // Options par défaut

  @override
  void initState() {
    super.initState();
    // Initialiser avec les données existantes si en mode édition
    if (widget.question != null) {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    // Initialiser tous les contrôleurs avec les données de la question existante
    final question = widget.question!;
    _quizzIdController.text = widget.quizz.id.toString();
    _textController.text = question.text;
    _pointsController.text = question.points.toString();
    _timeLimitController.text = question.timeLimit?.toString() ?? '30';
    // _orderController.text = question.or?.toString() ?? '1';
    _correctAnswerIndexController.text = question.correctAnswerIndex.toString();
    _codeSnippetController.text = question.codeSnippet ?? '';
    _explanationController.text = question.explanation ?? '';
    _type = question.type;
    
    // Initialiser les options si disponibles
    if (question.reponses != null && question.reponses is List) {
      _options = List<String>.from(question.reponses);
    }
    
    _correctAnswerIndex = question.correctAnswerIndex;
  }

  void _setCorrectAnswerIndex(int index) {
    setState(() {
      _correctAnswerIndex = index;
      _correctAnswerIndexController.text = index.toString();
    });
  }

  void _updateOption(int index, String value) {
    setState(() {
      _options[index] = value;
    });
  }

  void _addOption() {
    setState(() {
      _options.add('');
    });
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      // Préparer les données selon votre modèle
      final questionData = {
        'quizz_id': int.parse(_quizzIdController.text),
        'text': _textController.text,
        'type': _type,
        'points': int.parse(_pointsController.text),
        'time_limit': _timeLimitController.text.isNotEmpty ? int.parse(_timeLimitController.text) : null,
        'order': _orderController.text.isNotEmpty ? int.parse(_orderController.text) : null,
        'correct_answer_index': int.parse(_correctAnswerIndexController.text),
        'options': _type == 'multiple_choice' || _type == 'true_false' ? _options : null,
        'code_snippet': _codeSnippetController.text.isNotEmpty ? _codeSnippetController.text : null,
        'explanation': _explanationController.text.isNotEmpty ? _explanationController.text : null,
      };
      
      // Sauvegarder la question
      // widget.onSave(questionData);
      Navigator.pop(context, questionData);
    }
  }

  @override
  void dispose() {
    // Nettoyer tous les contrôleurs
    _quizzIdController.dispose();
    _textController.dispose();
    _pointsController.dispose();
    _timeLimitController.dispose();
    _orderController.dispose();
    _correctAnswerIndexController.dispose();
    _codeSnippetController.dispose();
    _explanationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
  return AlertDialog(
    title: Text(widget.question == null ? 'Ajouter une question' : 'Modifier la question'),
    content: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID du quiz (si nécessaire)
            TextFormField(
              controller: _quizzIdController,
              decoration: const InputDecoration(
                labelText: 'ID du Quiz *',
                border: OutlineInputBorder(),
                hintText: 'Entrez l\'ID du quiz',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'ID du quiz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Texte de la question
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Question *',
                border: OutlineInputBorder(),
                hintText: 'Entrez votre question',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une question';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Type de question
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Type de question *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'multiple_choice', child: Text('Choix multiple')),
                DropdownMenuItem(value: 'true_false', child: Text('Vrai/Faux')),
                DropdownMenuItem(value: 'code', child: Text('Avec extrait de code')),
                DropdownMenuItem(value: 'text', child: Text('Texte libre')),
              ],
              onChanged: (value) {
                setState(() {
                  _type = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner un type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Points
            TextFormField(
              controller: _pointsController,
              decoration: const InputDecoration(
                labelText: 'Points *',
                border: OutlineInputBorder(),
                hintText: '1',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nombre de points';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Limite de temps (en secondes)
            TextFormField(
              controller: _timeLimitController,
              decoration: const InputDecoration(
                labelText: 'Limite de temps (secondes)',
                border: OutlineInputBorder(),
                hintText: '30',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Ordre
            TextFormField(
              controller: _orderController,
              decoration: const InputDecoration(
                labelText: 'Ordre',
                border: OutlineInputBorder(),
                hintText: '1',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Options/réponses (pour les questions à choix multiple)
            if (_type == 'multiple_choice' || _type == 'true_false') ...[
              const Text(
                'Options:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Bouton de sélection de la bonne réponse
                      IconButton(
                        icon: Icon(
                          _correctAnswerIndex == index ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _correctAnswerIndex == index ? Colors.green : Colors.grey,
                        ),
                        onPressed: () => _setCorrectAnswerIndex(index),
                      ),
                      const SizedBox(width: 8),
                      // Champ de texte pour l'option
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(text: option),
                          decoration: InputDecoration(
                            hintText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) => _updateOption(index, value),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              // Bouton pour ajouter une option
              if (_type == 'multiple_choice')
                OutlinedButton(
                  onPressed: _addOption,
                  child: const Text('+ Ajouter une option'),
                ),
              const SizedBox(height: 16),
            ],

            // Index de la bonne réponse (pour tous les types)
            TextFormField(
              controller: _correctAnswerIndexController,
              decoration: const InputDecoration(
                labelText: 'Index de la bonne réponse *',
                border: OutlineInputBorder(),
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'index de la bonne réponse';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Extrait de code
            if (_type == 'code') ...[
              TextFormField(
                controller: _codeSnippetController,
                decoration: const InputDecoration(
                  labelText: 'Extrait de code',
                  border: OutlineInputBorder(),
                  hintText: 'Entrez votre code ici...',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
            ],

            // Explication
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Explication (optionnelle)',
                border: OutlineInputBorder(),
                hintText: 'Explication détaillée de la réponse',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      ElevatedButton(
        onPressed: _saveQuestion,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        child: const Text('Sauvegarder'),
      ),
    ],
  );
}
}