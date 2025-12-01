import 'package:flutter/material.dart';
import 'package:my_app/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/widgets/settings/reusable_widgets.dart';
import 'package:my_app/theme.dart';

class Settings extends StatefulWidget {
  final void Function(bool)? onThemeChanged;

  const Settings({super.key, this.onThemeChanged});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16.0),
          SettingsSection(
            title: 'General',
            children: [
              SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSetting('notifications', value);
                  },
                ),
              ),
              const Divider(height: 0),
              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    _saveSetting('darkMode', value);
                    widget.onThemeChanged?.call(value);
                  },
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Preferences',
            children: [
              SettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: () => _showLanguagePicker(context),
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyProfile(
                        orders: [],
                        favorites: [],
                        allItems: [],
                        onToggleFavorite: (String name) {},
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 0),
              SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                setState(() => _selectedLanguage = 'English');
                _saveSetting('language', 'English');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () {
                setState(() => _selectedLanguage = 'Spanish');
                _saveSetting('language', 'Spanish');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('French'),
              onTap: () {
                setState(() => _selectedLanguage = 'French');
                _saveSetting('language', 'French');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform logout action here
                Navigator.of(context).pop();
              },
              child: Text('Logout', style: TextStyle(color: AppTheme.error)),
            ),
          ],
        );
      },
    );
  }
}
