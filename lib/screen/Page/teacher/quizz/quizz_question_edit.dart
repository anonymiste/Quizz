
import 'package:flutter/material.dart';
import 'package:quizz_interface/models/questions.dart';
import 'package:quizz_interface/models/quizz.dart';

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
    _type = (question.type).toString();
    
    // Initialiser les options si disponibles
    if (question.reponses.isNotEmpty && question.reponses is List) {
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
                  _type = value!;
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