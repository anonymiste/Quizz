// enums/course_status.dart
enum CourseStatus {
  active('active'),
  archived('archived'),
  draft('draft');

  final String value;

  const CourseStatus(this.value);

  // Conversion depuis String
  static CourseStatus fromString(String value) {
    return CourseStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CourseStatus.draft,
    );
  }

  // Label pour l'affichage
  String get label {
    switch (this) {
      case CourseStatus.active:
        return "Actif";
      case CourseStatus.archived:
        return "Archivé";
      case CourseStatus.draft:
        return "Brouillon";
    }
  }

  // Couleur Material
  int get materialColor {
    switch (this) {
      case CourseStatus.active:
        return 0xFF4CAF50; // green
      case CourseStatus.archived:
        return 0xFF9E9E9E; // grey
      case CourseStatus.draft:
        return 0xFFFF9800; // orange
    }
  }

  // Icône
  String get icon {
    switch (this) {
      case CourseStatus.active:
        return "play_circle";
      case CourseStatus.archived:
        return "archive";
      case CourseStatus.draft:
        return "edit";
    }
  }

  // Est actif
  bool get isActive => this == CourseStatus.active;

  // Est archivé
  bool get isArchived => this == CourseStatus.archived;

  // Est brouillon
  bool get isDraft => this == CourseStatus.draft;

  // Liste des valeurs
  static List<String> get valuesList {
    return CourseStatus.values.map((status) => status.value).toList();
  }

  @override
  String toString() => value;
}