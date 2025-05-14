import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:farm_wise/Screen/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SpalshScreen();
        }
        final isLoggedIn = snapshot.hasData && snapshot.data != null;

        return isLoggedIn ? const MainScreen() :  const SpalshScreen();
      },
    );
  }
}