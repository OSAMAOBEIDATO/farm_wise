import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = "ProfileScreen";
  final String userId;
  const ProfileScreen({super.key,required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        toolbarHeight: 0, // hides appbar space
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar Circle
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green[900],
              child: const Text(
                'O',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            const Text(
              'Ibraheem Jardat',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Email Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, color: Colors.green[900]),
                const SizedBox(width: 6),
                const Text('ibraheem.b@gmail.com'),
              ],
            ),
            const SizedBox(height: 30),

            // Section: Account Settings
            sectionTitle('Account settings'),
            customListTile('Crop options', Icons.chevron_right, () {
              // TODO: Handle navigation
            }),
            customListTile('Notification management', Icons.chevron_right, () {
              // TODO: Handle navigation
            }),
            customListTile('Account security', Icons.chevron_right, () {
              // TODO: Handle navigation
            }),

            const SizedBox(height: 30),

            // Section: Help and Support
            sectionTitle('Help and Support'),
            customListTile('About FarmWise', Icons.chevron_right, () {
              // TODO: Handle navigation
            }),
            customListTile('Share the FarmWise app', Icons.chevron_right, () {
              // TODO: Handle navigation
            }),
          ],
        ),
      ),

      // Bottom Nav Bar

    );
  }

  // Helper: Section Title
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style:
          const TextStyle(
              fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // Helper: Custom List Tile
  Widget customListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: Icon(icon, color: Colors.black),
      onTap: onTap,
    );
  }
}