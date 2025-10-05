import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/enums/phase_level.dart';
import 'package:quizz_interface/models/cours.dart';
import 'package:quizz_interface/providers/teacher.dart';

class CourseEditDialog extends StatefulWidget {
  final Course course;
  final VoidCallback onCourseUpdated;

  const CourseEditDialog({
    super.key,
    required this.course,
    required this.onCourseUpdated,
  });

  @override
  State<CourseEditDialog> createState() => _CourseEditDialogState();
}

class _CourseEditDialogState extends State<CourseEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.course.title;
    _selectedLevel = widget.course.level;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le cours'),
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
                labelText: 'Niveau de difficulté',
                border: OutlineInputBorder(),
              ),
              items: PhaseLevel.values.map((level) {
                return DropdownMenuItem<String>(
                  value: level.value,
                  child: Text(level.label),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedLevel = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final teacherProvider = Provider.of<TeacherProvider>(
                context,
                listen: false,
              );

              final courseData = {
                'title': _titleController.text,
                'level': _selectedLevel,
              };

              final success = await teacherProvider.updateCourse(
                widget.course.id,
                courseData,
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                widget.onCourseUpdated();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cours modifié avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${teacherProvider.coursesError}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Modifier'),
        ),
      ],
    );
  }
}
 
