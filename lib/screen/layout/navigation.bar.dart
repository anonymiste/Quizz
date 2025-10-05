import 'package:flutter/material.dart';
import 'package:quizz_interface/models/users.dart';
import 'package:quizz_interface/screen/Auth/profile.dart';
import 'package:quizz_interface/screen/Page/admin/dashboard.dart';
import 'package:quizz_interface/screen/Page/admin/quizzes_management.dart';
import 'package:quizz_interface/screen/Page/admin/stats.dart';
import 'package:quizz_interface/screen/Page/admin/users_management.dart';
import 'package:quizz_interface/screen/Page/quizzliste.dart';
import 'package:quizz_interface/screen/Page/student/statistic.dart';
import 'package:quizz_interface/screen/Page/teacher/cours/cours_main.dart';
import 'package:quizz_interface/screen/Page/teacher/quizz/quizz_main.dart';
import 'package:quizz_interface/screen/Page/teacher/teacher.stats.dart';

class NavigationService {
  static List<BottomNavigationBarItem> getNavigationItems(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
        ];
      case 'teacher':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Cours',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Quiz',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];
      default: // student/user
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Classement',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];
    }
  }

  static List<Widget> getScreens(UserModel user, BuildContext context) {
    switch (user.role.toLowerCase()) {
      case 'admin':
        return _getAdminScreens(context);
      case 'teacher':
        return _getTeacherScreens(user, context);
      default: // student/user
        return _getStudentScreens(user);
    }
  }

  static List<String> getScreenLabels(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return ['Dashboard', 'Utilisateurs', 'Paramètres', 'Stats Détaillées'];
      case 'teacher':
        return ['Mes Cours', 'Quiz Créés', 'Analytiques', 'Profil'];
      default:
        return ['Accueil', 'Quiz', 'Classement', 'Profil'];
    }
  }

  static List<Widget> _getStudentScreens(UserModel user) {
    return [
      StatisticsScreen(userData: user.toJson()),
      QuizzListScreen(userData: user.toJson()),
      _buildPlaceholderScreen('Classement', Icons.leaderboard),
      ProfileScreen(),
    ];
  }

  static List<Widget> _getTeacherScreens(UserModel user, BuildContext context) {
    return [
      TeacherCoursesScreen(),
      TeacherQuizzesScreen(),
      TeacherStatsScreen(userData: user.toJson()),
      ProfileScreen(),
    ];
  }

  static List<Widget> _getAdminScreens(BuildContext context) {
    return [
      AdminDashboardScreen(),
      UsersManagementScreen(),
      AdminQuizzesScreen(),
      AdminStatsScreen(),
    ];
  }

  static Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Fonctionnalité en développement',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
