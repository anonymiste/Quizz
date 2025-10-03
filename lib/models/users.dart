class UserModel {
  final int? id;
  final String? name;
  final String email;
  final String role;
  final int? total;

  UserModel({
    this.id,
    this.name,
    required this.email,
    required this.role,
    this.total,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0'),
      name: json['name']?.toString(),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0'),    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'total': total,
    };
  }

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isTeacher => role.toLowerCase() == 'teacher';
  bool get isStudent => role.toLowerCase() == 'student';
}