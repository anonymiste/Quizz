import 'package:quizz_interface/enums/question_type.dart';
import 'package:quizz_interface/models/reponse.dart';

class Question {
  final String id;
  final String text;
  final List<Reponse> reponses;
  final int correctAnswerIndex;
  final String? explanation;
  final String? codeSnippet;
  final QuestionType type;
  final int points;
  final Duration? timeLimit;

  Question({
    required this.id,
    required this.text,
    required this.reponses,
    required this.correctAnswerIndex,
    required this.explanation,
    this.codeSnippet,
    this.type = QuestionType.multipleChoice,
    this.points = 10,
    this.timeLimit,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      reponses: (json['reponses'] ?? json['options'] ?? []).map((reponse) {
        if (reponse is Map<String, dynamic>) {
          return Reponse.fromJson(reponse);
        }
        return Reponse(
          body: reponse.toString(),
          value: '',
          check: false,
          questionId: json['id']?.toString() ?? '',
        );
      }).toList(),
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
      explanation: json['explanation']?.toString() ?? '',
      codeSnippet: json['code_snippet']?.toString(),
      type: QuestionType.parseType(json['type']?.toString() ?? ''),
      points: json['points'] ?? 10,
      timeLimit: json['time_limit'] != null
          ? Duration(minutes: json['time_limit'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'reponses': reponses.map((reponse) => reponse.toJson()).toList(),
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'code_snippet': codeSnippet,
      'type': _typeToString(type),
      'points': points,
      'time_limit': timeLimit?.inMinutes,
    };
  }

  String _typeToString(QuestionType type) {
    switch (type) {
      case QuestionType.code:
        return 'code';
      case QuestionType.trueFalse:
        return 'true_false';
      case QuestionType.practical:
        return 'practical';
      default:
        return 'multiple_choice';
    }
  }

  bool get hasCodeSnippet => codeSnippet != null && codeSnippet!.isNotEmpty;
  bool get isTimed => timeLimit != null;
}


