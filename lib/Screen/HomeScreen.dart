import 'package:farm_wise/Screen/CropCalendarScreen.dart';
import 'package:farm_wise/Screen/CropsScreen.dart';
import 'package:farm_wise/Screen/DiseaseScreen.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:farm_wise/Screen/ProfileScreen.dart';
import 'package:farm_wise/components/CardWeatherTile.dart';
import 'package:farm_wise/service/Authentication.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "HomeScreen";
  final String userId;
  //TODO: Auth Facbook and Apple
  //TODO:Add Search screen
  //TODO:Profile Screen
  // TODO:Home Screen

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize the list of screens to display
    _screens = [
      // Home screen content (current weather view)
      _buildHomeContent(),
      CropsScreen(userId: widget.userId),
      DiseaseScreen(userId: widget.userId),
      CropCalendarScreen(userId: widget.userId,),
      ProfileScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
              children: [
                CardWeatherTile(
                  icon: Icons.wb_sunny,
                  value: '13°C',
                  label: 'Partially sunny',
                  iconColor: Colors.orange,
                ),
                CardWeatherTile(// TODO ADD CROP FOR FIREBASE
                  icon: Icons.cloud,
                  value: '10%',
                  label: 'Precipitation',
                  iconColor: Colors.blue,
                ),
                CardWeatherTile(
                  icon: Icons.opacity,
                  value: '61%',
                  label: 'Humidity',
                  iconColor: Colors.blue,
                ),
                CardWeatherTile(
                  icon: Icons.air,
                  value: '5 km/h',
                  label: 'Wind',
                  iconColor: Colors.grey,
                ),
                CardWeatherTile(
                  icon: Icons.terrain,
                  value: '24.5%',
                  label: 'Soil moisture',
                  iconColor: Colors.brown,
                ),
                CardWeatherTile(
                  icon: Icons.check_circle,
                  value: 'Healthy',
                  label: 'Crop Health',
                  iconColor: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmWise'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  LoginScreen(userId: widget.userId,)),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Crops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Disease',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}