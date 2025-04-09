import 'package:farm_wise/Models/UserModel.dart';
import 'package:farm_wise/service/Authentication.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = 'ProfileScreen';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<UserModel?>(
        future: AuthService().getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Error loading profile.'));
          }

          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: Text('Name: ${user.firstName} ${user.lastName}'),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.green),
                  title: Text('Email: ${user.email}'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: Text('Phone: ${user.phone}'),
                ),
                ListTile(
                  leading: const Icon(Icons.date_range, color: Colors.green),
                  title: Text(
                    'Joined: ${user.createdAt?.toString().split(' ')[0] ?? 'N/A'}',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
