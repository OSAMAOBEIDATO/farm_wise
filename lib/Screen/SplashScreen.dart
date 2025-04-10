import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:flutter/material.dart';

class SpalshScreen extends StatefulWidget {
  static const String id = 'SpalshScreen';
  final String userId;

  const SpalshScreen({super.key, required this.userId});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>LoginScreen(userId: widget.userId,)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/Image/splashScreen.png',
          height: 900,
          width: 800,
        ),
      ),
    );
  }
}
