enum UserRole {
  student('Étudiant'),
  user('Utilisateur'),
  teacher('Enseignant'),
  admin('Administrateur');

  final String label;
  const UserRole(this.label);

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
      case 'enseignant':
        return UserRole.teacher;
      case 'student':
      case 'étudiant':
        return UserRole.student;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  @override
  String toString() => label;
}