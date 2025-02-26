import '../Views/Setting.dart';
import 'package:flutter/material.dart';
import '../Views/History.dart';
import '../Views/List_view.dart';
import '../views/Notification.dart';
import '../Services/auth_service.dart';
import '../Services/auth_gate.dart';
import '../Services/delivery_manager.dart';
import '../Model/Task.dart';

class Menu extends StatelessWidget {
  final Task? acceptedTask;
  Menu({Key? key, this.acceptedTask}) : super(key: key);

  final authservice = AuthService();
  final authgate = AuthGate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SectionHeader(title: "General"),
          SettingsOption(
            icon: Icons.person_outline,
            title: "Account information",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          SettingsOption(
            icon: Icons.list_outlined,
            title: "Item Listings",
            onTap: () {
              if (acceptedTask != null) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         ListItemsPage(items: acceptedTask!.packages),
                //   ),
                // );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No task has been accepted.")),
                );
              }
            },
          ),
          SettingsOption(
            icon: Icons.history_rounded,
            title: "History",
            onTap: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HistoryPage()),
              );
            },
          ),
//           SettingsOption(
//             icon: Icons.notifications_rounded,
//             title: "Notifications",
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => NotificationPage()),
//               );
//             },
//           ),
          const SizedBox(height: 24.0),
          const SectionHeader(title: "Support"),
          SettingsOption(
            icon: Icons.error_outline,
            title: "Report an issue",
            onTap: () {
              // Handle navigation
            },
          ),
          SettingsOption(
            icon: Icons.help_outline,
            title: "FAQ",
            onTap: () {
              // Handle navigation
            },
          ),
          const SizedBox(height: 36.0),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  authservice.logout(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text(
                  "Log out",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: const Border(
        bottom: BorderSide(color: Colors.grey, width: 0.5),
      ),
    );
  }
}
