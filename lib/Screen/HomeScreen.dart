import 'package:farm_wise/comman/consta.dart';
import 'package:farm_wise/components/CardWeatherTile.dart';
import 'package:flutter/material.dart';

// Home Screen (Weather Today)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Farm Wise",
          style: KTextStyle,
        ),
      ),
      body: Padding(
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
                  CardWeatherTile(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'Recommendations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Disease',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Crops',
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

        // To support more than 5 items
      ),
    );
  }
}
