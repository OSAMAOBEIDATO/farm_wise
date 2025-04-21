// HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:farm_wise/components/CardWeatherTile.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
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
              children:  [
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
    );
  }
}
