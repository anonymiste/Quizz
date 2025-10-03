import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/models/users.dart';
import 'package:quizz_interface/providers/auth.dart';
import 'package:quizz_interface/screen/Auth/login.dart';
import 'package:quizz_interface/screen/Page/admin/settings_admin.dart';
import 'package:quizz_interface/screen/Page/setting.dart';
import 'package:quizz_interface/screen/layout/navigation.bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Color _getAppBarColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.orange;
      case 'student':
        return Colors.blue;
      default:
        return const Color.fromARGB(255, 74, 111, 165);
    }
  }

  Color _getSelectedColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.orange;
      case 'student':
        return Colors.blue;
      default:
        return const Color.fromARGB(255, 74, 111, 165);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    final navItems = NavigationService.getNavigationItems(user.role);
    final screens = NavigationService.getScreens(user, context);
    final labels = NavigationService.getScreenLabels(user.role);

    return Scaffold(
      appBar: AppBar(
        title: Text(labels[_currentIndex]),
        backgroundColor: _getAppBarColor(user.role),
        foregroundColor: Colors.white,
        actions: [
          Chip(
            label: Text(
              user.role.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            backgroundColor: _getAppBarColor(user.role),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _getSelectedColor(user.role),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      drawer: _buildDrawer(user, authProvider),
    );
  }

  Widget _buildDrawer(UserModel user, AuthProvider authProvider) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name ?? 'Utilisateur'),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name?.isNotEmpty == true
                    ? user.name![0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: BoxDecoration(color: _getAppBarColor(user.role)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('Rôle: ${user.role.toUpperCase()}'),
          ),
          ListTile(leading: const Icon(Icons.email), title: Text(user.email)),
          const Divider(),
          if (user.isAdmin) ..._getAdminDrawerItems(),
          if (user.isTeacher) ..._getTeacherDrawerItems(),
          ..._getCommonDrawerItems(authProvider, user),
        ],
      ),
    );
  }

  List<Widget> _getAdminDrawerItems() {
    return [
      ListTile(
        leading: const Icon(Icons.security),
        title: const Text('Administration'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminSettingsScreen()),
          );
        },
      ),
      const Divider(),
    ];
  }

  List<Widget> _getTeacherDrawerItems() {
    return [
      ListTile(
        leading: const Icon(Icons.school),
        title: const Text('Gestion des Cours'),
        onTap: () {
          Navigator.pop(context);
          // Naviguer vers la gestion des cours
        },
      ),
      const Divider(),
    ];
  }

  List<Widget> _getCommonDrawerItems(
    AuthProvider authProvider,
    UserModel user,
  ) {
    return [
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Paramètres'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Déconnexion'),
        onTap: () {
          authProvider.logout(user);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    ];
  }
}
