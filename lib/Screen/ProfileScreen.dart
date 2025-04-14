import 'package:flutter/material.dart';
import 'package:farm_wise/Screen/SignUpScreen.dart';

// Helper widget for building list tiles (frontend only)
Widget _buildListTile(BuildContext context, {required String title, required VoidCallback onTap, Color? textColor}) {
  return ListTile(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        color: textColor ?? Colors.black,
      ),
    ),
    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    onTap: onTap,
  );
}

class ProfilePage extends StatelessWidget {
  static const String id = "ProfilePage";
  final String userId; // Kept for consistency, but not used in frontend

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Hardcoded placeholder data for frontend display
    const String name = 'User';
    const String email = 'user@example.com';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email, color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(
                    context,
                    title: 'Account settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon!')),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Crop options',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon!')),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Notification management',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon!')),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Account security',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon!')),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Help & Support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon!')),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'About FarmWise',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon!')),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Share the FarmWise app',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon!')),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Logout',
                    onTap: () {
                      // Navigate to SignUpScreen without backend logic
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen(userId: '')),
                            (route) => false,
                      );
                    },
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}