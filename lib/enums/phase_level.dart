
enum PhaseLevel {
  undefined('undefined'),
  easy('easy'),
  medium('medium'),
  hard('hard');

  final String value;

  const PhaseLevel(this.value);

  // Conversion depuis String
  static PhaseLevel fromString(String value) {
    return PhaseLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => PhaseLevel.undefined,
    );
  }

  // Label pour l'affichage
  String get label {
    switch (this) {
      case PhaseLevel.undefined:
        return "Indéfinie";
      case PhaseLevel.easy:
        return "Facile";
      case PhaseLevel.medium:
        return "Moyen";
      case PhaseLevel.hard:
        return "Difficile";
    }
  }

  // Couleur pour l'UI
  String get color {
    switch (this) {
      case PhaseLevel.undefined:
        return "grey";
      case PhaseLevel.easy:
        return "green";
      case PhaseLevel.medium:
        return "yellow";
      case PhaseLevel.hard:
        return "red";
    }
  }

  // Couleur Material
  int get materialColor {
    switch (this) {
      case PhaseLevel.undefined:
        return 0xFF9E9E9E; // grey
      case PhaseLevel.easy:
        return 0xFF4CAF50; // green
      case PhaseLevel.medium:
        return 0xFFFFC107; // amber
      case PhaseLevel.hard:
        return 0xFFF44336; // red
    }
  }

  // Icône
  String get icon {
    switch (this) {
      case PhaseLevel.undefined:
        return "help_outline";
      case PhaseLevel.easy:
        return "sentiment_very_satisfied";
      case PhaseLevel.medium:
        return "sentiment_satisfied";
      case PhaseLevel.hard:
        return "sentiment_very_dissatisfied";
    }
  }

  // Liste des valeurs
  static List<String> get valuesList {
    return PhaseLevel.values.map((level) => level.value).toList();
  }

  // Liste pour les dropdowns
static List<Map<String, dynamic>> get dropdownItems {
  return PhaseLevel.values.map((level) => {
    'value': level.value,
    'label': level.label,
    'color': level.materialColor,
    'icon': level.icon,
  }).toList();
}

  @override
  String toString() => value;
}