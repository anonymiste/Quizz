import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/enums/phase_level.dart';
import 'package:quizz_interface/enums/quizz_tech_cat%C3%A9gory.dart';
import 'package:quizz_interface/providers/teacher.dart';

class CourseCreationDialog extends StatefulWidget {
  final VoidCallback onCourseCreated;

  const CourseCreationDialog({super.key, required this.onCourseCreated});

  @override
  State<CourseCreationDialog> createState() => _CourseCreationDialogState();
}

class _CourseCreationDialogState extends State<CourseCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedLevel = PhaseLevel.easy.value;
  String _selectedCategory = QuizzCategory.programming.value;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un nouveau cours'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre du cours *',
                border: OutlineInputBorder(),
                hintText: 'Entrez un titre unique pour votre cours',
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
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Niveau de difficulté *',
                border: OutlineInputBorder(),
              ),
              items: PhaseLevel.values.map((level) {
                return DropdownMenuItem<String>(
                  value: level.value,
                  child: Row(
                    children: [
                      Icon(
                        _getLevelIcon(level.icon),
                        color: Color(level.materialColor),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(level.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedLevel = value!),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner un niveau';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie *',
                border: OutlineInputBorder(),
              ),
              items: QuizzCategory.values.map((category) {
                return DropdownMenuItem<String>(
                  value: category.value,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category.icon),
                        color: Color(category.materialColor),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(category.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedCategory = value!),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner une catégorie';
                }
                return null;
              },
            ),
            if (_isSubmitting) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text(
                'Création du cours en cours...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Créer'),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final teacherProvider = Provider.of<TeacherProvider>(
        context,
        listen: false,
      );

      final courseData = {
        'title': _titleController.text.trim(),
        'level': _selectedLevel,
        'category': _selectedCategory,
        'average': 0,
      };

      print('🔄 Données du cours: $courseData');

      try {
        await teacherProvider.createCourse(courseData);

        // Fermer le dialogue d'abord, puis afficher le message
        if (mounted) {
          Navigator.pop(context);
        }

        // Utiliser un délai pour s'assurer que le dialogue est complètement fermé
        await Future.delayed(const Duration(milliseconds: 100));

        // Appeler le callback pour rafraîchir la liste
        widget.onCourseCreated();

        // Afficher le message de succès via le callback
        _showSuccessMessage();
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          _handleError(e.toString());
        }
      }
    }
  }

  void _showSuccessMessage() {
    // Stocker le context avant de fermer le dialogue
    final scaffoldContext = context;

    // Utiliser un délai pour s'assurer que le dialogue est fermé
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(
            content: Text('Cours créé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _handleError(String error) {
    final errorLower = error.toLowerCase();
    String userMessage;

    if (errorLower.contains('unique') ||
        errorLower.contains('title') ||
        errorLower.contains('titre')) {
      userMessage =
          'Un cours avec ce titre existe déjà. Veuillez choisir un autre titre.';
    } else if (errorLower.contains('category') ||
        errorLower.contains('catégorie') ||
        errorLower.contains('check')) {
      userMessage = 'La catégorie sélectionnée n\'est pas valide.';
    } else if (errorLower.contains('level') || errorLower.contains('niveau')) {
      userMessage = 'Le niveau sélectionné n\'est pas valide.';
    } else if (errorLower.contains('network') ||
        errorLower.contains('timeout') ||
        errorLower.contains('connection')) {
      userMessage = 'Erreur de connexion. Vérifiez votre connexion internet.';
    } else {
      userMessage = 'Erreur lors de la création du cours: $error';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  IconData _getLevelIcon(String iconName) {
    switch (iconName) {
      case 'help_outline':
        return Icons.help_outline;
      case 'sentiment_very_satisfied':
        return Icons.sentiment_very_satisfied;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied;
      case 'sentiment_very_dissatisfied':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'build':
        return Icons.build;
      case 'security':
        return Icons.security;
      case 'settings_ethernet':
        return Icons.settings_ethernet;
      case 'storage':
        return Icons.storage;
      case 'language':
        return Icons.language;
      case 'smartphone':
        return Icons.smartphone;
      case 'cloud':
        return Icons.cloud;
      case 'smart_toy':
        return Icons.smart_toy;
      default:
        return Icons.category;
    }
  }
}
