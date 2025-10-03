enum QuizzDifficulty {
  all('Tous'),
  beginner('Débutant'),
  intermediate('Intermédiaire'),
  advanced('Avancé'),
  expert('Expert');

  final String label;
  const QuizzDifficulty(this.label);

  static QuizzDifficulty parse(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'débutant':
        return QuizzDifficulty.beginner;
      case 'intermediate':
      case 'intermédiaire':
        return QuizzDifficulty.intermediate;
      case 'advanced':
      case 'avancé':
        return QuizzDifficulty.advanced;
      case 'expert':
        return QuizzDifficulty.expert;
      default:
        return QuizzDifficulty.all;
    }
  }

  @override
  String toString() => label;
}