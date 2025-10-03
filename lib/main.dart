import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/providers/admin.dart';
import 'package:quizz_interface/providers/auth.dart';
import 'package:quizz_interface/providers/quizz.dart';
import 'package:quizz_interface/providers/statistics.dart';
import 'package:quizz_interface/providers/teacher.dart';
import 'package:quizz_interface/screen/Auth/login.dart';
import 'package:quizz_interface/screen/Auth/register.dart';
import 'package:quizz_interface/screen/Page/home.dart';
import 'package:quizz_interface/services/quizz.api.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => StatisticsProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (_) => QuizzProvider(QuizzApiService())),
        ChangeNotifierProvider(
          create: (context) =>
              AdminProvider(Provider.of<AuthProvider>(context, listen: false)),
        ),
         ChangeNotifierProvider<TeacherProvider>(
          create: (context) => TeacherProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 74, 111, 165),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(title: 'Quizz App'),
        '/login': (context) => const LoginScreen(),
        '/register': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return RegisterScreen(userData: args);
        },
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isChecked = false;
  bool _isLoading = false;

  void _navigateToLogin() async {
    if (!_isChecked) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 255),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 74, 111, 165),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.quiz,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 74, 111, 165),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Bienvenue !",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(129, 198, 255, 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromRGBO(129, 198, 255, 0.3),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Termes et conditions d'utilisation",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 74, 111, 165),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "En utilisant cette application, vous acceptez nos termes et conditions.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (value) =>
                              setState(() => _isChecked = value!),
                          activeColor: const Color.fromARGB(255, 74, 111, 165),
                        ),
                        const Expanded(
                          child: Text(
                            "J'accepte les termes et conditions",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _isChecked ? _navigateToLogin : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isChecked
                                    ? const Color.fromARGB(255, 74, 111, 165)
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Commencer"),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
