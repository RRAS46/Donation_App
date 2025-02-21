import 'package:dash_flags/dash_flags.dart';
import 'package:donation_app_v1/const_values/title_values.dart';
import 'package:donation_app_v1/enums/currency_enum.dart';
import 'package:donation_app_v1/enums/drawer_enum.dart';
import 'package:donation_app_v1/enums/language_enum.dart';
import 'package:donation_app_v1/models/drawer_model.dart';
import 'package:donation_app_v1/models/settings_model.dart'; // Hive-enabled Settings model.
import 'package:donation_app_v1/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dash_flags/dash_flags.dart';

final _supabaseClient = Supabase.instance.client;

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _hasImageError = false;

  @override
  void initState(){
    super.initState();
    final profileProvider=Provider.of<ProfileProvider>(context,listen: false);
    profileProvider.updateSettings(getCurrentSettingsFromHive());

  }
  @override
  void dispose() {
    // This will be called when the user leaves the page
    print("User is leaving settings page. Saving changes...");
    updateProfileSettings(); // Save settings
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final settings = profileProvider.profile!.settings;
    bool isDarkMode = settings.theme == "dark";

    return Scaffold(
      appBar: AppBar(
        title: Text(PageTitles.getTitle(profileProvider.profile!.settings.language, 'settings_page_title'), style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: DonationAppDrawer(drawerIndex: DrawerItem.settings.index,),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.tealAccent.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildProfileSection(),
            Expanded(
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 16,horizontal: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16,horizontal: 4),
                  child: ListView(
                    children: [
                      // Notification toggle
                      _buildSettingsSwitch(
                        title: "Enable Notifications",
                        value: settings.notificationsEnabled,
                        icon: Icons.notifications,
                        onChanged: (val) {
                          final newSettings = settings.copyWith(notificationsEnabled: val);
                          _updateSettings(newSettings, profileProvider);
                        },
                      ),
                      // Dark mode toggle
                      _buildSettingsSwitch(
                        title: "Dark Mode",
                        value: isDarkMode,
                        icon: Icons.dark_mode,
                        onChanged: (val) {
                          final newSettings = settings.copyWith(theme: val ? "dark" : "light");
                          _updateSettings(newSettings, profileProvider);
                        },
                      ),
                      // Language dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: _buildLanguageDropdown(profileProvider),
                      ),
                      // Currency dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: _buildCurrencyDropdown(profileProvider),
                      ),
                      // Font size slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: _buildFontSizeSlider(profileProvider),
                      ),
                      // Privacy mode toggle
                      _buildSettingsSwitch(
                        title: "Privacy Mode",
                        value: settings.privacyMode,
                        icon: Icons.lock,
                        onChanged: (val) {
                          final newSettings = settings.copyWith(privacyMode: val);
                          _updateSettings(newSettings, profileProvider);
                        },
                      ),
                      // Accent color dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: _buildAccentColorDropdown(profileProvider),
                      ),
                      // Notification sound dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: _buildNotificationSoundDropdown(profileProvider),
                      ),
                      // Layout mode dropdown
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: _buildLayoutModeDropdown(profileProvider),
                      ),
                      Divider(),
                      _buildSettingsItem("Privacy Policy", Icons.privacy_tip, _showPrivacyPolicy),
                      _buildSettingsItem("Terms & Conditions", Icons.description, _showTerms),
                      Divider(),
                      _buildSettingsItem("About", Icons.info, _showAboutDialog),
                      _buildSettingsItem("Logout", Icons.exit_to_app, _logout, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profile Section
  Widget _buildProfileSection() {
    final user = _supabaseClient.auth.currentUser;
    final username = user?.userMetadata?['username'] ?? 'User';
    final email = user?.email ?? 'tempUser@example.com';
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.teal.shade700,
            foregroundImage: _hasImageError
                ? AssetImage('assets/images/default.png')
                : NetworkImage(profileProvider.profile!.imageUrl) as ImageProvider,
            onForegroundImageError: (exception, stackTrace) {
              setState(() => _hasImageError = true);
              print("Error loading image: $exception");
            },
            child: _hasImageError
                ? Text(
              (user?.userMetadata?['username'] ?? "User")[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.white,
              ),
            )
                : null,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(email, style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  // Switch widget used for toggles.
  Widget _buildSettingsSwitch({
    required String title,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      secondary: Icon(icon, color: Colors.green.shade700),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
    );
  }

  // General list item widget.
  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap, {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Language dropdown widget.

  Widget _buildLanguageDropdown(ProfileProvider profileProvider) {
    Languages currentLanguage = Languages.values.firstWhere((element) => element.code == profileProvider.profile!.settings.language,);

    return Row(
      children: [
        Icon(Icons.language, color: Colors.green.shade700),
        SizedBox(width: 16),
        Flexible(
          child: DropdownButtonFormField<Languages>(
            decoration: InputDecoration(
              labelText: "Select Language",
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: currentLanguage,
            dropdownColor: Colors.white,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.teal, size: 28),
            style: TextStyle(fontSize: 16, color: Colors.black87),
            items: Languages.values.map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Row(
                  children: [
                    Text(lang.code),
                    SizedBox(width: 8),
                    Text(
                      lang.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis, // Adds "..." if text overflows
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final newSettings = profileProvider.profile!.settings.copyWith(language: value.code);
                _updateSettings(newSettings, profileProvider);
              }
            },
          ),
        ),
      ],
    );
  }

  // Currency dropdown widget.
  Widget _buildCurrencyDropdown(ProfileProvider profileProvider) {
    Currency currentCurrency = Currency.values.firstWhere((element) => element.code == profileProvider.profile!.settings.currency,);

    return Row(
      children: [
        Icon(Icons.attach_money, color: Colors.green.shade700),
        SizedBox(width: 16),
        Flexible(
          child: DropdownButtonFormField<Currency>(
            decoration: InputDecoration(
              labelText: "Select Currency",
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: currentCurrency,
            dropdownColor: Colors.white,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.teal, size: 28),
            style: TextStyle(fontSize: 16, color: Colors.black87),
            items: Currency.values.map((cur) {
              return DropdownMenuItem(
                value: cur,
                child: Row(
                  children: [
                    Text(
                      cur.symbol,
                      style: TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 150,// Allows text to wrap instead of overflowing
                      child: Text(
                        cur.getString,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis, // Adds "..." if text overflows
                      ),
                    ),
                  ],
                ),
              );

            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final newSettings = profileProvider.profile!.settings.copyWith(currency: value.code);
                _updateSettings(newSettings, profileProvider);
              }
            },
          ),
        ),

      ],
    );
  }

  // Font size slider widget.
  Widget _buildFontSizeSlider(ProfileProvider profileProvider) {
    double currentFontSize = profileProvider.profile!.settings.fontSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Font Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Slider(
          min: 10.0,
          max: 30.0,
          divisions: 20,
          label: currentFontSize.toStringAsFixed(1),
          value: currentFontSize,
          onChanged: (val) {
            final newSettings = profileProvider.profile!.settings.copyWith(fontSize: val);
            _updateSettings(newSettings, profileProvider);
          },
        ),
      ],
    );
  }

  // Accent color dropdown widget.
  Widget _buildAccentColorDropdown(ProfileProvider profileProvider) {
    // Define some example colors with their string representation.
    final Map<String, int> colorOptions = {
      'Teal': Colors.teal.value,
      'Blue': Colors.blue.value,
      'Red': Colors.red.value,
      'Green': Colors.green.value,
    };

    // Find the current color name by matching the value.
    String currentColorName = colorOptions.entries
        .firstWhere((entry) => entry.value == profileProvider.profile!.settings.accentColor,
        orElse: () => MapEntry('Teal', Colors.teal.value))
        .key;

    return Row(
      children: [
        Icon(Icons.color_lens, color: Colors.green.shade700),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Accent Color",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            value: currentColorName,
            items: colorOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.key),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final newSettings = profileProvider.profile!.settings.copyWith(accentColor: colorOptions[value]);
                _updateSettings(newSettings, profileProvider);
              }
            },
          ),
        ),
      ],
    );
  }

  // Notification sound dropdown widget.
  Widget _buildNotificationSoundDropdown(ProfileProvider profileProvider) {
    final List<String> sounds = ['default', 'chime', 'alert'];
    String currentSound = profileProvider.profile!.settings.notificationSound;

    return Row(
      children: [
        Icon(Icons.music_note, color: Colors.green.shade700),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Notification Sound",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            value: currentSound,
            items: sounds.map((sound) {
              return DropdownMenuItem(
                value: sound,
                child: Text(sound.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final newSettings = profileProvider.profile!.settings.copyWith(notificationSound: value);
                _updateSettings(newSettings, profileProvider);
              }
            },
          ),
        ),
      ],
    );
  }

  // Layout mode dropdown widget.
  Widget _buildLayoutModeDropdown(ProfileProvider profileProvider) {
    final List<String> layouts = ['compact', 'comfortable'];
    String currentLayout = profileProvider.profile!.settings.layoutMode;

    return Row(
      children: [
        Icon(Icons.view_agenda, color: Colors.green.shade700),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Layout Mode",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            value: currentLayout,
            items: layouts.map((layout) {
              return DropdownMenuItem(
                value: layout,
                child: Text(layout[0].toUpperCase() + layout.substring(1)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final newSettings = profileProvider.profile!.settings.copyWith(layoutMode: value);
                _updateSettings(newSettings, profileProvider);
              }
            },
          ),
        ),
      ],
    );
  }

  // About dialog
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "Donation App",
      applicationVersion: "1.0.0",
      applicationLegalese: "© 2025 FlexCode Studios",
    );
  }

  // Privacy Policy dialog
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Privacy Policy"),
        content: SingleChildScrollView(child: Text("Your privacy policy details go here...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
        ],
      ),
    );
  }

  // Terms dialog
  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Terms & Conditions"),
        content: SingleChildScrollView(child: Text("Your terms and conditions details go here...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
        ],
      ),
    );
  }

  Future<void> updateProfileSettings() async {
    final supabase = Supabase.instance.client;
    final profileProvider=Provider.of<ProfileProvider>(context,listen: false);
    final response = await supabase
        .from('profiles') // Ensure this is your correct table name
        .update({'settings': profileProvider.profile!.settings.toJson()})
        .eq('username', supabase.auth.currentUser!.userMetadata!['username']); // Match the correct user by ID

    if (response.error != null) {
      print("Error updating settings: ${response.error!.message}");
    } else {
      print("Settings updated successfully!");
    }
  }

  // --- Hive Integration Helpers ---
  Future<void> updateSettingsInHive(Settings newSettings) async {
    final settingsBox = Hive.box<Settings>('settingsBox');
    await settingsBox.put('userSettings', newSettings);
  }

  Settings getCurrentSettingsFromHive() {
    final settingsBox = Hive.box<Settings>('settingsBox');
    return settingsBox.get('userSettings', defaultValue: Settings.defaultSettings)!;
  }

  // Helper method to update settings in both Hive and Provider.
  void _updateSettings(Settings newSettings, ProfileProvider profileProvider) {
    updateSettingsInHive(newSettings);
    profileProvider.updateSettings(newSettings);
    updateProfileSettings();
  }

  // Logout action
  void _logout() {
    print("User Logged Out");
    _supabaseClient.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/signIn', (Route<dynamic> route) => false);
  }
}
