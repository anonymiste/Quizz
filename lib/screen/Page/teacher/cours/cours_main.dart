import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/enums/cours_status.dart';
import 'package:quizz_interface/models/cours.dart';
import 'package:quizz_interface/providers/teacher.dart';
import 'package:quizz_interface/enums/phase_level.dart';
import 'package:quizz_interface/screen/Page/teacher/cours/cours_create.dart';
import 'package:quizz_interface/screen/Page/teacher/cours/cours_edit.dart';
import 'package:quizz_interface/screen/Page/teacher/cours/cours_stats.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    final teacherProvider = Provider.of<TeacherProvider>(
      context,
      listen: false,
    );
    if (teacherProvider.isTeacher) {
      teacherProvider.refreshCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Mes Cours'),
      //   backgroundColor: Colors.orange,
      //   foregroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.add),
      //       onPressed: _createNewCourse,
      //       tooltip: 'Créer un nouveau cours',
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.refresh),
      //       onPressed: _loadCourses,
      //       tooltip: 'Actualiser',
      //     ),
      //   ],
      // ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (!teacherProvider.isTeacher) {
            return _buildNotTeacherState();
          }

          return Column(
            children: [
              // Barre de recherche et filtres
              _buildSearchAndFilters(),
              const SizedBox(height: 8),

              // Liste des cours
              Expanded(child: _buildCourseList(teacherProvider)),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (!teacherProvider.isTeacher) return const SizedBox();

          return FloatingActionButton(
            onPressed: _createNewCourse,
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            heroTag: 'teacher_courses_fab',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildNotTeacherState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Accès réservé aux enseignants',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Cette fonctionnalité n\'est disponible que pour les enseignants',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Barre de recherche
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un cours...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12), // Changé de height à width
          // Dropdown pour les filtres
          Container(
            width: 150, // Largeur fixe ou utiliser Expanded si nécessaire
            child: DropdownButtonFormField<String>(
              value:
                  _selectedFilter, // Assurez-vous d'avoir cette variable définie
              decoration: InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous')),
                DropdownMenuItem(value: 'active', child: Text('Actifs')),
                DropdownMenuItem(value: 'archived', child: Text('Archivés')),
                DropdownMenuItem(value: 'draft', child: Text('Brouillons')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildFilterChip(String label, String value) {
  //   return FilterChip(
  //     label: Text(label),
  //     selected: _selectedFilter == value,
  //     onSelected: (selected) => setState(() => _selectedFilter = value),
  //     selectedColor: Colors.orange.shade100,
  //     checkmarkColor: Colors.orange,
  //     labelStyle: TextStyle(
  //       color: _selectedFilter == value ? Colors.orange : Colors.grey[700],
  //     ),
  //   );
  // }

  Widget _buildCourseList(TeacherProvider teacherProvider) {
    if (teacherProvider.isLoadingCourses) {
      return _buildLoading();
    }

    if (teacherProvider.hasCoursesError) {
      return _buildErrorState(teacherProvider);
    }

    if (teacherProvider.courses.isEmpty) {
      return _buildEmptyState();
    }

    final filteredCourses = _filterCourses(teacherProvider.courses);

    if (filteredCourses.isEmpty) {
      return _buildNoResultsState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadCourses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredCourses.length,
        itemBuilder: (context, index) =>
            _buildCourseCard(filteredCourses[index], teacherProvider),
      ),
    );
  }

  Widget _buildCourseCard(Course course, TeacherProvider provider) {
    final courseStatus = CourseStatus.fromString(course.status);
    final phaseLevel = PhaseLevel.fromString(course.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(phaseLevel.materialColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.class_,
            color: Color(phaseLevel.materialColor),
            size: 30,
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.description.length > 60
                  ? '${course.description.substring(0, 60)}...'
                  : course.description,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    phaseLevel.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(phaseLevel.materialColor),
                    ),
                  ),
                  backgroundColor: Color(
                    phaseLevel.materialColor,
                  ).withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    '${course.quizCount} quiz',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.green.shade50,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    courseStatus.value.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(courseStatus.materialColor),
                    ),
                  ),
                  backgroundColor: Color(
                    courseStatus.materialColor,
                  ).withOpacity(0.1),
                ),
              ],
            ),
            if (course.average > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Moyenne: ${course.average.toStringAsFixed(1)}/20',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.blue.shade700),
                title: const Text('Modifier'),
              ),
            ),
            PopupMenuItem(
              value: 'stats',
              child: ListTile(
                leading: Icon(Icons.analytics, color: Colors.green.shade700),
                title: const Text('Statistiques'),
              ),
            ),
            if (!courseStatus.isArchived)
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.archive, color: Colors.orange.shade700),
                  title: const Text('Archiver'),
                ),
              ),
            if (courseStatus.isArchived)
              PopupMenuItem(
                value: 'activate',
                child: ListTile(
                  leading: Icon(Icons.unarchive, color: Colors.green.shade700),
                  title: const Text('Activer'),
                ),
              ),
          ],
          onSelected: (value) => _handleCourseAction(value, course, provider),
        ),
        onTap: () => _viewCourseDetails(course),
      ),
    );
  }

  List<Course> _filterCourses(List<Course> courses) {
    var filtered = courses;

    // Filtre par statut
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((course) => course.status == _selectedFilter)
          .toList();
    }

    // Filtre par recherche
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (course) =>
                course.title.toLowerCase().contains(searchLower) ||
                course.description.toLowerCase().contains(searchLower) ||
                course.level.toLowerCase().contains(searchLower) ||
                course.category.toLowerCase().contains(searchLower),
          )
          .toList();
    }

    return filtered;
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des cours...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(TeacherProvider teacherProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, color: Colors.red.shade700),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              teacherProvider.coursesError,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadCourses,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Aucun cours créé',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Commencez par créer votre premier cours',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _createNewCourse,
            icon: const Icon(Icons.add),
            label: const Text('Créer un cours'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Aucun résultat trouvé',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _createNewCourse() {
    showDialog(
      context: context,
      builder: (context) => CourseCreationDialog(onCourseCreated: _loadCourses),
    );
  }

  void _viewCourseDetails(Course course) {
    // Naviguer vers les détails du cours
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails du cours: ${course.title}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleCourseAction(
    String action,
    Course course,
    TeacherProvider provider,
  ) {
    switch (action) {
      case 'edit':
        _editCourse(course, provider);
        break;
      case 'stats':
        _viewCourseStats(course, provider);
        break;
      case 'archive':
        _archiveCourse(course, provider);
        break;
      case 'activate':
        _activateCourse(course, provider);
        break;
    }
  }

  void _editCourse(Course course, TeacherProvider provider) {
    showDialog(
      context: context,
      builder: (context) =>
          CourseEditDialog(course: course, onCourseUpdated: _loadCourses),
    );
  }

  void _viewCourseStats(Course course, TeacherProvider provider) async {
    final statistics = await provider.getCourseStatistics(course.id);
    if (statistics != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) =>
            CourseStatisticsDialog(course: course, statistics: statistics),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${provider.coursesError}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _archiveCourse(Course course, TeacherProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver le cours'),
        content: Text(
          'Êtes-vous sûr de vouloir archiver le cours "${course.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.archiveCourse(course.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cours "${course.title}" archivé'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${provider.coursesError}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  void _activateCourse(Course course, TeacherProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activer le cours'),
        content: Text(
          'Êtes-vous sûr de vouloir activer le cours "${course.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.activateCourse(course.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cours "${course.title}" activé'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${provider.coursesError}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }
}


