class Course {
  final int id;
  final String title;
  final String description;
  final String category;
  final int teacherId;
  final int studentCount;
  final int quizCount;
  final String status;
  final double average;
  final String level;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.teacherId,
    required this.studentCount,
    required this.quizCount,
    required this.status,
    required this.average,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Phase',
      teacherId: json['teacher_id'] is String ? 
          int.parse(json['teacher_id']) : json['teacher_id'],
      studentCount: json['student_count'] ?? 0,
      quizCount: json['quiz_count'] ?? 0,
      status: json['status'] ?? 'active',
      average: (json['average'] ?? 0).toDouble(),
      level: json['level'] ?? 'undefined',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'level': level,
      'category': category,
      'average': average,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'level': level,
      'category': category,
      'average': average,
    };
  }

  String get levelLabel {
    switch (level) {
      case 'easy':
        return 'Facile';
      case 'medium':
        return 'Moyen';
      case 'hard':
        return 'Difficile';
      case 'undefined':
      default:
        return 'Indéfini';
    }
  }

  String get levelColor {
    switch (level) {
      case 'easy':
        return 'green';
      case 'medium':
        return 'yellow';
      case 'hard':
        return 'red';
      case 'undefined':
      default:
        return 'grey';
    }
  }
}