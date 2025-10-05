import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/enums/quizz_dificulty.dart';
import 'package:quizz_interface/models/quizz.dart';
import 'package:quizz_interface/providers/teacher.dart';
import 'package:quizz_interface/screen/Page/teacher/quizz/quizz_create.dart';
import 'package:quizz_interface/screen/Page/teacher/quizz/quizz_detail.dart';
import 'package:quizz_interface/screen/Page/teacher/quizz/quizz_edit.dart';
import 'package:quizz_interface/screen/Page/teacher/quizz/quizz_question.dart';
import 'package:quizz_interface/screen/Page/teacher/quizz/quizz_stats.dart';

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
      MaterialPageRoute(builder: (context) => QuizQuestionsScreen(quiz: quiz)),
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
      MaterialPageRoute(builder: (context) => QuizDetailScreen(quiz: quiz)),
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
