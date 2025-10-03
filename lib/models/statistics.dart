class StatisticsModel {
  final UserStatsUser user;
  final UserStatsStatistics statistics;
  final List<UserStatsPhase> phasesProgress;
  final UserStatsRank rank;
  final List<UserStatsRecentActivity>? recentActivity;

  StatisticsModel({
    required this.user,
    required this.statistics,
    required this.phasesProgress,
    required this.rank,
    this.recentActivity,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      user: UserStatsUser.fromJson(json['user'] ?? {}),
      statistics: UserStatsStatistics.fromJson(json['statistics'] ?? {}),
      phasesProgress: (json['phases_progress'] as List? ?? [])
          .map((phase) => UserStatsPhase.fromJson(phase))
          .toList(),
      rank: UserStatsRank.fromJson(json['rank'] ?? {}),
      recentActivity: (json['recent_activity'] as List?)
          ?.map((activity) => UserStatsRecentActivity.fromJson(activity))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'statistics': statistics.toJson(),
      'phases_progress': phasesProgress.map((phase) => phase.toJson()).toList(),
      'rank': rank.toJson(),
      'recent_activity': recentActivity?.map((activity) => activity.toJson()).toList(),
    };
  }
}

class UserStatsUser {
  final int id;
  final String name;
  final String email;
  final String role;

  UserStatsUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserStatsUser.fromJson(Map<String, dynamic> json) {
    return UserStatsUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Utilisateur',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class UserStatsStatistics {
  final int totalPoints;
  final int quizzesCompleted;
  final int correctAnswers;
  final int incorrectAnswers;
  final double successRate;
  final int currentStreak;
  final int bestStreak;
  final int totalTimeSpent;
  final double averageScore;

  UserStatsStatistics({
    required this.totalPoints,
    required this.quizzesCompleted,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.successRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalTimeSpent,
    required this.averageScore,
  });

  factory UserStatsStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatsStatistics(
      totalPoints: json['total_points'] ?? 0,
      quizzesCompleted: json['quizzes_completed'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      incorrectAnswers: json['incorrect_answers'] ?? 0,
      successRate: (json['success_rate'] ?? 0.0).toDouble(),
      currentStreak: json['current_streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      totalTimeSpent: json['total_time_spent'] ?? 0,
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_points': totalPoints,
      'quizzes_completed': quizzesCompleted,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'success_rate': successRate,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'total_time_spent': totalTimeSpent,
      'average_score': averageScore,
    };
  }
}

class UserStatsPhase {
  final String phase;
  final int progress;
  final int points;
  final String? updatedAt;

  UserStatsPhase({
    required this.phase,
    required this.progress,
    required this.points,
    this.updatedAt,
  });

  factory UserStatsPhase.fromJson(Map<String, dynamic> json) {
    return UserStatsPhase(
      phase: json['phase']?.toString() ?? '',
      progress: json['progress'] ?? 0,
      points: json['points'] ?? 0,
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase,
      'progress': progress,
      'points': points,
      'updated_at': updatedAt,
    };
  }
}

class UserStatsRank {
  final String rank;
  final int level;

  UserStatsRank({
    required this.rank,
    required this.level,
  });

  factory UserStatsRank.fromJson(Map<String, dynamic> json) {
    return UserStatsRank(
      rank: json['rank']?.toString() ?? 'Nouveau',
      level: json['level'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'level': level,
    };
  }
}

class UserStatsRecentActivity {
  final String quiz;
  final int score;
  final String date;

  UserStatsRecentActivity({
    required this.quiz,
    required this.score,
    required this.date,
  });

  factory UserStatsRecentActivity.fromJson(Map<String, dynamic> json) {
    return UserStatsRecentActivity(
      quiz: json['quiz']?.toString() ?? '',
      score: json['score'] ?? 0,
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz': quiz,
      'score': score,
      'date': date,
    };
  }
}

class QuizResultModel {
  final int points;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpentMinutes;
  final String? phaseName;
  final int? phaseProgress;

  QuizResultModel({
    required this.points,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpentMinutes,
    this.phaseName,
    this.phaseProgress,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'time_spent_minutes': timeSpentMinutes,
      if (phaseName != null) 'phase_name': phaseName,
      if (phaseProgress != null) 'phase_progress': phaseProgress,
    };
  }
}

class LeaderboardEntry {
  final int rank;
  final String userName;
  final String userEmail;
  final int totalPoints;
  final int quizzesCompleted;
  final double successRate;

  LeaderboardEntry({
    required this.rank,
    required this.userName,
    required this.userEmail,
    required this.totalPoints,
    required this.quizzesCompleted,
    required this.successRate,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userName: json['user_name']?.toString() ?? json['user']?['name']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? json['user']?['email']?.toString() ?? '',
      totalPoints: json['total_points'] ?? 0,
      quizzesCompleted: json['quizzes_completed'] ?? 0,
      successRate: (json['success_rate'] ?? 0.0).toDouble(),
    );
  }
}