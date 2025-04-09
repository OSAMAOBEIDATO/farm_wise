import 'package:farm_wise/Models/UserModel.dart';
import 'package:farm_wise/service/Authentication.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = "ProfileScreen";
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('ProfileScreen'),
      ),
    );
  }
}
