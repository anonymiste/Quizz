
enum QuizzCategory {
  programming('programming'),
  maintenance('maintenance'),
  cybersecurity('cybersecurity'),
  networking('networking'),
  database('database'),
  web('web'),
  mobile('mobile'),
  cloud('cloud'),
  ai('ai');

  final String value;

  const QuizzCategory(this.value);

  // Conversion depuis String
  static QuizzCategory fromString(String value) {
    return QuizzCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => QuizzCategory.programming,
    );
  }

  // Label pour l'affichage
  String get label {
    switch (this) {
      case QuizzCategory.programming:
        return "Programmation";
      case QuizzCategory.maintenance:
        return "Maintenance";
      case QuizzCategory.cybersecurity:
        return "Cybersécurité";
      case QuizzCategory.networking:
        return "Réseaux";
      case QuizzCategory.database:
        return "Base de données";
      case QuizzCategory.web:
        return "Web";
      case QuizzCategory.mobile:
        return "Mobile";
      case QuizzCategory.cloud:
        return "Cloud";
      case QuizzCategory.ai:
        return "Intelligence Artificielle";
    }
  }

  // Icône Material Icons
  String get icon {
    switch (this) {
      case QuizzCategory.programming:
        return "code";
      case QuizzCategory.maintenance:
        return "build";
      case QuizzCategory.cybersecurity:
        return "security";
      case QuizzCategory.networking:
        return "settings_ethernet";
      case QuizzCategory.database:
        return "storage";
      case QuizzCategory.web:
        return "language";
      case QuizzCategory.mobile:
        return "smartphone";
      case QuizzCategory.cloud:
        return "cloud";
      case QuizzCategory.ai:
        return "smart_toy";
    }
  }

  // Couleur Material
  int get materialColor {
    switch (this) {
      case QuizzCategory.programming:
        return 0xFF2196F3; // blue
      case QuizzCategory.maintenance:
        return 0xFF795548; // brown
      case QuizzCategory.cybersecurity:
        return 0xFFF44336; // red
      case QuizzCategory.networking:
        return 0xFF4CAF50; // green
      case QuizzCategory.database:
        return 0xFFFF9800; // orange
      case QuizzCategory.web:
        return 0xFF9C27B0; // purple
      case QuizzCategory.mobile:
        return 0xFF00BCD4; // cyan
      case QuizzCategory.cloud:
        return 0xFF607D8B; // blue grey
      case QuizzCategory.ai:
        return 0xFFE91E63; // pink
    }
  }

  // Description
  String get description {
    switch (this) {
      case QuizzCategory.programming:
        return "Quiz sur la programmation et le développement logiciel";
      case QuizzCategory.maintenance:
        return "Quiz sur la maintenance informatique et systèmes";
      case QuizzCategory.cybersecurity:
        return "Quiz sur la sécurité informatique et cybersécurité";
      case QuizzCategory.networking:
        return "Quiz sur les réseaux et communications";
      case QuizzCategory.database:
        return "Quiz sur les bases de données et SQL";
      case QuizzCategory.web:
        return "Quiz sur le développement web";
      case QuizzCategory.mobile:
        return "Quiz sur le développement mobile";
      case QuizzCategory.cloud:
        return "Quiz sur le cloud computing";
      case QuizzCategory.ai:
        return "Quiz sur l'intelligence artificielle et machine learning";
    }
  }

  // Liste des valeurs
  static List<String> get valuesList {
    return QuizzCategory.values.map((category) => category.value).toList();
  }

  // Liste pour les dropdowns
static List<Map<String, dynamic>> get dropdownItems {
  return QuizzCategory.values.map((category) => {
    'value': category.value,
    'label': category.label,
    'icon': category.icon,
    'color': category.materialColor,
    'description': category.description,
  }).toList();
}

  @override
  String toString() => value;
}