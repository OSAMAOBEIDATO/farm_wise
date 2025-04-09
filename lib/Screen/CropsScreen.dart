import 'package:flutter/material.dart';

class CropsScreen extends StatefulWidget {
  static const String id = "CropsScreen";
  final String userId;

  const CropsScreen({super.key, required this.userId});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Crops Screen"),
      ),
    );
  }
}
