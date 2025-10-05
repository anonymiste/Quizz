import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/enums/quizz_tech_cat%C3%A9gory.dart';
import 'package:quizz_interface/providers/teacher.dart';

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
