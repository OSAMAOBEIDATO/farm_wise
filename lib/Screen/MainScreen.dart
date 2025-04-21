// MainScreen.dart
import 'package:flutter/material.dart';
import 'package:farm_wise/Screen/HomeScreen.dart';
import 'package:farm_wise/Screen/CropCalendarScreen.dart';
import 'package:farm_wise/Screen/DiseaseScreen.dart';
import 'package:farm_wise/Screen/ProfileScreen.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:farm_wise/service/Authentication.dart';

class MainScreen extends StatefulWidget {
  static const String id = "MainScreen";
  final String userId;

  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userId: widget.userId),
      CropDiseaseDetectionScreen(userId: widget.userId),
      CropCalendarScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmWise'),
        backgroundColor: Colors.green,

      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Disease'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
