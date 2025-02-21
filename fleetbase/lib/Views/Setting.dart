import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/auth_service.dart'; // Assume this contains your authentication logic

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _username = 'Loading...';
  late String _email = 'Loading...';
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French'];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadPreferences();
  }

  Future<void> _loadUserInfo() async {
    final user = await _authService.getUserName();
    final email = await _authService.getCurrentUserEmail();
    setState(() {
      _username = user ?? 'No username';
      _email = email ?? 'No email';
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Information Section
          _buildUserInfoCard(),
          const SizedBox(height: 20),

          // Security Section
          _buildSectionHeader('Security'),
          _buildPasswordChangeCard(),
          const SizedBox(height: 20),

          // App Settings Section
          _buildSectionHeader('App Settings'),
          _buildNotificationSettings(),
          _buildLanguageSettings(),
          const SizedBox(height: 20),

          
        
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      color: Colors.white, // Set background color to white
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Account Information',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey)),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black54),
              title:
                  const Text('Username', style: TextStyle(color: Colors.grey)),
              subtitle: Text(_username,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              enabled: false,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.black54),
              title: const Text('Email', style: TextStyle(color: Colors.grey)),
              subtitle: Text(_email,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey)),
    );
  }

  Widget _buildPasswordChangeCard() {
    return Card(
      color: Colors.white, // Set background color to white
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.lock_reset, color: Colors.black54),
        title: const Text('Change Password',
            style: TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () => _showCurrentPasswordDialog(context),
      ),
    );
  }

  void _showCurrentPasswordDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Verify Identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              minLines: 1,
              maxLength: 20,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final currentPassword = controller.text;
              if (controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter your current password'),
                      backgroundColor: Colors.red),
                );
                return;
              }
              if (currentPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              Navigator.pop(context);
              _showNewPasswordDialog(context);
            },
            child: const Text('Continue',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNewPasswordDialog(BuildContext context) {
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set New Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_reset),
                labelText: 'New Password',
                helperText: 'Minimum 6 characters',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                counterText: '',
              ),
              maxLength: 20,
              minLines: 1,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_reset),
                labelText: 'Confirm Password',
                helperText: 'Re-enter new password',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                counterText: '',
              ),
              maxLength: 20,
              minLines: 1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('Update Password',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newPassword = newController.text;
              final confirmPassword = confirmController.text;

              if (newPassword.isEmpty || confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Passwords do not match!'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Password updated successfully!'),
                    backgroundColor: Colors.green),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      color: Colors.white, // Set background color to white
      elevation: 2,
      child: SwitchListTile(
        title: const Text('Enable Notifications'),
        secondary: const Icon(Icons.notifications, color: Colors.black54),
        value: _notificationsEnabled,
        onChanged: (value) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('notifications', value);
          setState(() => _notificationsEnabled = value);
        },
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return Card(
      color: Colors.white, // Set background color to white
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.language, color: Colors.black54),
        title: const Text('App Language'),
        subtitle: Text(_selectedLanguage),
        trailing: DropdownButton<String>(
          value: _selectedLanguage,
          items: _languages
              .map((lang) =>
                  DropdownMenuItem(value: lang, child: Text(lang)))
              .toList(),
          onChanged: (value) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('language', value!);
            setState(() => _selectedLanguage = value);
          },
        ),
      ),
    );
  }

  
}
