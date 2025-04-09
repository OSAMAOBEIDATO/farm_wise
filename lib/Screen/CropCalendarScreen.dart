import 'package:flutter/material.dart';

class CropCalendarScreen extends StatefulWidget {
  static const String id = "ProfileScreen";
  final String userId;

  const CropCalendarScreen({super.key, required this.userId});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Crop Cleaner'),
      ),
    );
  }
}
