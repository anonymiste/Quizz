import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _autoRefreshEnabled = true;
  bool _maintenanceMode = false;
  double _autoRefreshInterval = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres Administrateur'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête Admin
          _buildAdminHeader(),
          const SizedBox(height: 20),

          // Section Maintenance
          _buildSectionHeader('Maintenance Système', Icons.build),
          Card(
            child: Column(
              children: [
                _buildSwitchSetting(
                  'Mode Maintenance',
                  _maintenanceMode,
                  Icons.engineering,
                  onChanged: (value) => setState(() => _maintenanceMode = value),
                  subtitle: 'Bloque l\'accès aux utilisateurs normaux',
                ),
                _buildDivider(),
                _buildSettingItem(
                  'Vider le cache',
                  'Supprimer tous les caches',
                  Icons.cached,
                  onTap: _clearCache,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Surveillance
          _buildSectionHeader('Surveillance', Icons.monitor_heart),
          Card(
            child: Column(
              children: [
                _buildSwitchSetting(
                  'Auto-rafraîchissement',
                  _autoRefreshEnabled,
                  Icons.autorenew,
                  onChanged: (value) => setState(() => _autoRefreshEnabled = value),
                ),
                _buildDivider(),
                _buildSliderSetting(
                  'Intervalle de rafraîchissement',
                  _autoRefreshInterval,
                  Icons.timer,
                  min: 10,
                  max: 300,
                  divisions: 10,
                  label: '${_autoRefreshInterval}s',
                  onChanged: (value) => setState(() => _autoRefreshInterval = value.toDouble()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Données
          _buildSectionHeader('Gestion des Données', Icons.data_usage),
          Card(
            child: Column(
              children: [
                _buildSettingItem(
                  'Export des données',
                  'Exporter en CSV/JSON',
                  Icons.import_export,
                  onTap: _exportData,
                  color: Colors.green,
                ),
                _buildDivider(),
                _buildSettingItem(
                  'Sauvegarde manuelle',
                  'Créer un backup',
                  Icons.backup,
                  onTap: _createBackup,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Actions critiques
          _buildSectionHeader('Actions Critiques', Icons.warning),
          Card(
            color: Colors.red.shade50,
            child: Column(
              children: [
                _buildDangerousSetting(
                  'Réinitialiser les statistiques',
                  'Remet à zéro toutes les stats',
                  Icons.restart_alt,
                  onTap: _resetStatistics,
                ),
                _buildDivider(),
                _buildDangerousSetting(
                  'Archiver les anciens quiz',
                  'Déplace les quiz inactifs',
                  Icons.archive,
                  onTap: _archiveOldQuizzes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 40, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panel Administrateur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accès complet aux paramètres système',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
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
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
      onTap: onTap,
    );
  }

  Widget _buildDangerousSetting(
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(
        title,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.red),
      ),
      trailing: const Icon(Icons.warning, color: Colors.red),
      onTap: onTap,
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    IconData icon, {
    required ValueChanged<bool> onChanged,
    String subtitle = '',
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.red,
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    double value,
    IconData icon, {
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: label,
                  onChanged: onChanged,
                  activeColor: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56);
  }

  // Méthodes pour les actions
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text('Êtes-vous sûr de vouloir vider tous les caches système ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache vidé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Vider le cache'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter les données'),
        content: const Text('Choisissez le format d\'export :'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Export CSV');
            },
            child: const Text('CSV'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Export JSON');
            },
            child: const Text('JSON'),
          ),
        ],
      ),
    );
  }

  void _createBackup() {
    _showComingSoon('Sauvegarde manuelle');
  }

  void _resetStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les statistiques'),
        content: const Text('Cette action est irréversible. Toutes les statistiques seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Réinitialisation des statistiques');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _archiveOldQuizzes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver les anciens quiz'),
        content: const Text('Les quiz inactifs depuis plus de 6 mois seront archivés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Archivage des quiz');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fonctionnalité à venir'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}