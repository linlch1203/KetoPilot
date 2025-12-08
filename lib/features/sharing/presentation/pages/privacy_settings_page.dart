import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/themes/app_theme.dart';

@RoutePage()
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  // Default settings
  bool _shareGlucose = true;
  bool _shareKetones = true;
  bool _shareMacros = true;
  bool _shareWeight = false; // Default to private
  bool _shareNotes = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shareGlucose = prefs.getBool('privacy_share_glucose') ?? true;
      _shareKetones = prefs.getBool('privacy_share_ketones') ?? true;
      _shareMacros = prefs.getBool('privacy_share_macros') ?? true;
      _shareWeight = prefs.getBool('privacy_share_weight') ?? false;
      _shareNotes = prefs.getBool('privacy_share_notes') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Biometrics'),
          _buildSwitchTile(
            title: 'Share Glucose Readings',
            subtitle: 'Include glucose mg/dL values in shared cards',
            value: _shareGlucose,
            onChanged: (val) {
              setState(() => _shareGlucose = val);
              _saveSetting('privacy_share_glucose', val);
            },
            icon: Icons.water_drop,
            color: Colors.orange,
          ),
          _buildSwitchTile(
            title: 'Share Ketone Levels',
            subtitle: 'Include BHB mmol/L values in shared cards',
            value: _shareKetones,
            onChanged: (val) {
              setState(() => _shareKetones = val);
              _saveSetting('privacy_share_ketones', val);
            },
            icon: Icons.science,
            color: Colors.purple,
          ),
          _buildSwitchTile(
            title: 'Share Weight',
            subtitle: 'Include body weight in progress updates',
            value: _shareWeight,
            onChanged: (val) {
              setState(() => _shareWeight = val);
              _saveSetting('privacy_share_weight', val);
            },
            icon: Icons.monitor_weight,
            color: Colors.blue,
          ),
          
          _buildSectionHeader('Nutrition & Lifestyle'),
          _buildSwitchTile(
            title: 'Share Macros',
            subtitle: 'Include daily Carbs, Protein, and Fat totals',
            value: _shareMacros,
            onChanged: (val) {
              setState(() => _shareMacros = val);
              _saveSetting('privacy_share_macros', val);
            },
            icon: Icons.pie_chart,
            color: AppTheme.primaryColor,
          ),
          _buildSwitchTile(
            title: 'Share Notes',
            subtitle: 'Include personal reflection notes',
            value: _shareNotes,
            onChanged: (val) {
              setState(() => _shareNotes = val);
              _saveSetting('privacy_share_notes', val);
            },
            icon: Icons.note,
            color: Colors.grey,
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'These settings control what data is visible by default when you generate a new Share Card. You can always override these settings for individual cards.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      activeColor: AppTheme.primaryColor,
    );
  }
}
