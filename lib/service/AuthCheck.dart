import 'dart:async';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:farm_wise/Screen/SplashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isConnectedToInternet = false;
  bool isCheckingConnection = true;
  StreamSubscription? internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _checkInitialConnectivity() async {
    final isConnected = await InternetConnection().hasInternetAccess;
    if (mounted) {
      setState(() {
        isConnectedToInternet = isConnected;
        isCheckingConnection = false;
      });
    }
  }

  void _setupConnectivityListener() {
    internetConnectionStreamSubscription =
        InternetConnection().onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          isConnectedToInternet = status == InternetStatus.connected;
        });
      }
    });
  }

  @override
  void dispose() {
    internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingConnection) {
      return const SpalshScreen();
    }

    if (!isConnectedToInternet) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.signal_wifi_off,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please check your connection and try again'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isCheckingConnection = true;
                  });
                  await _checkInitialConnectivity();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SpalshScreen(); // Fixed typo here
        }
        final isLoggedIn = snapshot.hasData && snapshot.data != null;

        return isLoggedIn
            ? const MainScreen()
            : const SpalshScreen();
      },
    );
  }
}
