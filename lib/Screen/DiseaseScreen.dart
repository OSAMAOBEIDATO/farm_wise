import 'package:flutter/material.dart';

class DiseaseScreen extends StatelessWidget {
  static const String id = "DiseaseScreen";
  final String userId;

  const DiseaseScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Camera for AI '),
      ),
    );
  }
}
