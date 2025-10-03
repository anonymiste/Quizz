class AdminDashboardStats {
  final int totalUsers;
  final int totalTeachers;
  final int totalStudents;
  final int totalQuizzes;
  final int totalPhases;
  final int onlineUsers;
  final int totalQuizAttempts;
  final int totalPointsDistributed;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalTeachers,
    required this.totalStudents,
    required this.totalQuizzes,
    required this.totalPhases,
    required this.onlineUsers,
    required this.totalQuizAttempts,
    required this.totalPointsDistributed,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: _safeParseInt(json['total_users']),
      totalTeachers: _safeParseInt(json['total_teachers']),
      totalStudents: _safeParseInt(json['total_students']),
      totalQuizzes: _safeParseInt(json['total_quizzes']),
      totalPhases: _safeParseInt(json['total_phases']),
      onlineUsers: _safeParseInt(json['online_users']),
      totalQuizAttempts: _safeParseInt(json['total_quiz_attempts']),
      totalPointsDistributed: _safeParseInt(json['total_points_distributed']),
    );
  }

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_teachers': totalTeachers,
      'total_students': totalStudents,
      'total_quizzes': totalQuizzes,
      'total_phases': totalPhases,
      'online_users': onlineUsers,
      'total_quiz_attempts': totalQuizAttempts,
      'total_points_distributed': totalPointsDistributed,
    };
  }
}