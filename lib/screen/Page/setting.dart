import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_interface/providers/auth.dart';
import 'package:quizz_interface/screen/Page/admin/settings_admin.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  String _selectedLanguage = 'Français';
  String _selectedTheme = 'Auto';

  final List<String> _languages = ['Français', 'English', 'Español'];
  final List<String> _themes = ['Auto', 'Clair', 'Sombre'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),

        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Profil
          _buildSectionHeader('Profil'),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  authProvider.currentUser?.name
                          ?.substring(0, 1)
                          .toUpperCase() ??
                      'U',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                authProvider.currentUser?.name ?? 'Utilisateur',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(authProvider.currentUser?.email ?? 'Non connecté'),
              trailing: const Icon(Icons.edit, color: Colors.grey),
              onTap: () => _editProfile(),
            ),
          ),
          const SizedBox(height: 20),

          // Section Apparence
          _buildSectionHeader('Apparence'),
          Card(
            child: Column(
              children: [
                _buildSettingItem(
                  'Thème',
                  _selectedTheme,
                  Icons.palette,
                  onTap: () => _showThemeSelector(),
                ),
                _buildDivider(),
                _buildSettingItem(
                  'Langue',
                  _selectedLanguage,
                  Icons.language,
                  onTap: () => _showLanguageSelector(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Notifications
          _buildSectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                _buildSwitchSetting(
                  'Notifications',
                  _notificationsEnabled,
                  Icons.notifications,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                _buildDivider(),
                _buildSwitchSetting(
                  'Son',
                  _soundEnabled,
                  Icons.volume_up,
                  onChanged: (value) => setState(() => _soundEnabled = value),
                  enabled: _notificationsEnabled,
                ),
                _buildDivider(),
                _buildSwitchSetting(
                  'Vibration',
                  _vibrationEnabled,
                  Icons.vibration,
                  onChanged: (value) =>
                      setState(() => _vibrationEnabled = value),
                  enabled: _notificationsEnabled,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Préférences de quiz
          _buildSectionHeader('Préférences de Quiz'),
          Card(
            child: Column(
              children: [
                _buildSettingItem(
                  'Difficulté par défaut',
                  'Moyenne',
                  Icons.school,
                  onTap: () => _showDifficultySelector(),
                ),
                _buildDivider(),
                _buildSettingItem(
                  'Temps par question',
                  '30 secondes',
                  Icons.timer,
                  onTap: () => _showTimeSelector(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Confidentialité
          _buildSectionHeader('Confidentialité'),
          Card(
            child: Column(
              children: [
                _buildSettingItem(
                  'Politique de confidentialité',
                  '',
                  Icons.privacy_tip,
                  onTap: () => _showPrivacyPolicy(),
                ),
                _buildDivider(),
                _buildSettingItem(
                  'Conditions d\'utilisation',
                  '',
                  Icons.description,
                  onTap: () => _showTermsOfService(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Compte
          _buildSectionHeader('Compte'),
          Card(
            child: Column(
              children: [
                _buildDivider(),
                _buildSettingItem(
                  'Déconnexion',
                  '',
                  Icons.logout,
                  color: Colors.blue,
                  onTap: () => _logout(context),
                ),
                if (authProvider.currentUser?.role == 'admin') ...[
                  _buildDivider(),
                  _buildSettingItem(
                    'Paramètres administrateur',
                    '',
                    Icons.admin_panel_settings,
                    color: Colors.orange,
                    onTap: () => _openAdminSettings(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section À propos
          _buildSectionHeader('À propos'),
          Card(
            child: Column(
              children: [
                _buildSettingItem('Version', '1.0.0', Icons.info, onTap: () {}),
                _buildDivider(),
                _buildSettingItem(
                  'Aide & Support',
                  '',
                  Icons.help,
                  onTap: () => _showHelp(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon, {
    Color color = Colors.grey,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    IconData icon, {
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: enabled ? Colors.grey : Colors.grey.shade300),
      title: Text(
        title,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey.shade400),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56);
  }

  // Méthodes pour les actions
  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: const Text(
          'Cette fonctionnalité sera disponible prochainement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir un thème',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._themes.map(
              (theme) => ListTile(
                leading: Icon(
                  theme == _selectedTheme ? Icons.check : null,
                  color: Colors.blue,
                ),
                title: Text(theme),
                onTap: () {
                  setState(() => _selectedTheme = theme);
                  Navigator.pop(context);
                  _showComingSoon();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir une langue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._languages.map(
              (language) => ListTile(
                leading: Icon(
                  language == _selectedLanguage ? Icons.check : null,
                  color: Colors.blue,
                ),
                title: Text(language),
                onTap: () {
                  setState(() => _selectedLanguage = language);
                  Navigator.pop(context);
                  _showComingSoon();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultySelector() {
    _showComingSoon();
  }

  void _showTimeSelector() {
    _showComingSoon();
  }

  void _showPrivacyPolicy() {
    _showComingSoon();
  }

  void _showTermsOfService() {
    _showComingSoon();
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              // authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _openAdminSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminSettingsScreen()),
    );
  }

  void _showHelp() {
    _showComingSoon();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
