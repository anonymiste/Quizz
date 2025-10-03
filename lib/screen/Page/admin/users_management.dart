import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/models/users.dart';
import 'package:quizz_interface/providers/admin.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'all';
  bool _showCreateForm = false;
  bool _initialLoadComplete = false;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _initializeUsers();
  }

  void _initializeUsers() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      // CORRECTION : Attendre le chargement
      await _loadUsers();

      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
          _lastUpdate = DateTime.now();
        });

        adminProvider.startUsersAutoRefresh();
      }
    });
  }

  // CORRECTION : Retourner Future<void>
  Future<void> _loadUsers() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.loadUsers(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      role: _selectedRole == 'all' ? null : _selectedRole,
    );
  }

  @override
  void dispose() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminProvider.stopUsersAutoRefresh();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Gestion des Utilisateurs'),
      //   backgroundColor: Colors.red,
      //   foregroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh),
      //       onPressed: _loadUsers,
      //       tooltip: 'Actualiser',
      //     ),
      //     _buildLastUpdateIcon(),
      //   ],
      // ),
      body: _showCreateForm
          ? _buildCreateUserForm()
          : Column(
              children: [
                _buildFilters(),
                Expanded(child: _buildUsersList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showCreateForm = !_showCreateForm),
        backgroundColor: _showCreateForm ? Colors.grey : Colors.red,
        foregroundColor: Colors.white,
        child: Icon(_showCreateForm ? Icons.close : Icons.person_add),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      // color: Colors.grey[50],
      child: Row(
        children: [
          // CORRECTION : Ajouter Expanded autour du TextField
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadUsers();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) _loadUsers();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // CORRECTION : Optionnel - Ajouter une largeur fixe au Dropdown
          SizedBox(
            width: 150, // Largeur fixe pour le dropdown
            child: DropdownButton<String>(
              isExpanded: true, // Pour utiliser toute la largeur disponible
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'teacher', child: Text('Enseignant')),
                DropdownMenuItem(value: 'student', child: Text('Étudiant')),
                DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
              ],
              onChanged: (value) {
                setState(() => _selectedRole = value!);
                _loadUsers();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateUserForm() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController totalController = TextEditingController(
      text: '0',
    );
    String selectedRole = 'user';

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_add, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Créer un nouvel utilisateur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Rôle *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment_ind),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('Utilisateur'),
                      ),
                      DropdownMenuItem(
                        value: 'student',
                        child: Text('Étudiant'),
                      ),
                      DropdownMenuItem(
                        value: 'teacher',
                        child: Text('Enseignant'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrateur'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedRole = value;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: totalController,
                    decoration: const InputDecoration(
                      labelText: 'Total (points)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.emoji_events),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showCreateForm = false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // CORRECTION : Validation améliorée
                      if (nameController.text.isEmpty ||
                          emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Veuillez remplir tous les champs obligatoires (*)',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Validation email
                      if (!emailController.text.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez entrer un email valide'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      int totalValue;
                      try {
                        totalValue = int.tryParse(totalController.text) ?? 0;
                      } catch (e) {
                        totalValue = 0;
                      }

                      final newUser = UserModel(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        role: selectedRole,
                        total: totalValue,
                      );

                      _createUser(newUser);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Créer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.users.isNotEmpty) {
          _lastUpdate = DateTime.now();
        }

        if (!_initialLoadComplete && adminProvider.users.isEmpty) {
          return _buildLoading();
        }

        if (adminProvider.hasError) {
          return _buildError(adminProvider);
        }

        if (adminProvider.users.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildListHeader(adminProvider.users.length),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: adminProvider.users.length,
                itemBuilder: (context, index) =>
                    _buildUserCard(adminProvider.users[index], adminProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des utilisateurs...'),
        ],
      ),
    );
  }

  Widget _buildError(AdminProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loadUsers, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun utilisateur trouvé',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count utilisateur${count > 1 ? 's' : ''} trouvé${count > 1 ? 's' : ''}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Row(
            children: [
              Icon(Icons.autorenew, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Auto-actualisé',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, AdminProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.name?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name ?? 'Sans nom',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: _getRoleColor(user.role),
                ),
                if (user.total != null && user.total! > 0)
                  Chip(
                    label: Text(
                      '${user.total} pts',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Modifier'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Supprimer'),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditUserDialog(user, provider);
            } else if (value == 'delete') {
              _showDeleteUserDialog(user, provider);
            }
          },
        ),
      ),
    );
  }

  // Dans _buildLastUpdateIcon(), remplacer Tooltip par :
  Widget _buildLastUpdateIcon() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _lastUpdate != null
                  ? 'Dernière MAJ: ${_lastUpdate!.hour}:${_lastUpdate!.minute.toString().padLeft(2, '0')}'
                  : 'Chargement...',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(Icons.autorenew, color: Colors.green, size: 20),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.orange;
      case 'student':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // CORRECTION : Méthode améliorée pour créer un utilisateur
  Future<void> _createUser(UserModel newUser) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    try {
      final success = await adminProvider.createUser(newUser);

      if (success && mounted) {
        setState(() => _showCreateForm = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadUsers(); // Recharger la liste
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${adminProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditUserDialog(UserModel user, AdminProvider provider) {
    final TextEditingController nameController = TextEditingController(
      text: user.name,
    );
    final TextEditingController emailController = TextEditingController(
      text: user.email,
    );
    final TextEditingController totalController = TextEditingController(
      text: user.total?.toString() ?? '0',
    );
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                  DropdownMenuItem(value: 'student', child: Text('Étudiant')),
                  DropdownMenuItem(value: 'teacher', child: Text('Enseignant')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrateur'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: totalController,
                decoration: const InputDecoration(labelText: 'Total'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Veuillez remplir tous les champs obligatoires (*)',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              int totalValue;
              try {
                totalValue = int.tryParse(totalController.text) ?? 0;
              } catch (e) {
                totalValue = 0;
              }

              try {
                UserModel userData = UserModel(
                  id: user.id!,
                  name: nameController.text,
                  email: emailController.text,
                  role: selectedRole,
                  total: totalValue,
                );
                final success = await provider.updateUser(userData);

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Utilisateur mis à jour'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _loadUsers();
                  } else {
                      print(provider.errorMessage);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${provider.errorMessage}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(UserModel user, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.name}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await provider.deleteUser(user.id!);

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Utilisateur supprimé'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _loadUsers();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${provider.errorMessage}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
