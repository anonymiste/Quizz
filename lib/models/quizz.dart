import 'package:quizz_interface/models/questions.dart';

class Quizz {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String status;
  final List<Question> questions;
  final int? bestScore;
  final int timeLimit;
  final DateTime createdAt;
  final int participants;
  final double rating;

  Quizz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.status,
    required this.questions,
    this.bestScore,
    required this.timeLimit,
    required this.createdAt,
    this.participants = 0,
    this.rating = 0.0,
  });

  factory Quizz.fromJson(Map<String, dynamic> json) {
    return Quizz(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Sans titre',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'programming',
      difficulty: json['difficulty']?.toString() ?? 'beginner',
      status: json['status']?.toString() ?? 'published',
      questions: (json['questions'] as List? ?? []).map((q) {
        if (q is Map<String, dynamic>) {
          return Question.fromJson(q);
        }
        return Question.fromJson({}); // Question vide
      }).toList(),
      bestScore: json['best_score'],
      timeLimit: json['time_limit'] ?? 30,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      participants: json['participants'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'status': status,
      'questions': questions.map((q) => q.toJson()).toList(),
      'best_score': bestScore,
      'time_limit': timeLimit,
      'created_at': createdAt.toIso8601String(),
      'participants': participants,
      'rating': rating,
    };
  }

  String get estimatedTime => '$timeLimit min';
  int get questionCount => questions.length;
  bool get isCompleted => bestScore != null;
  double get completionRate => isCompleted ? (bestScore! / 100) : 0.0;
}