import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:farm_wise/service/WeatherService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:farm_wise/components/CardWeatherTile.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CropData> _userCrops = [];
  bool _isLoadingCrops = true;
  String? _fetchError;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Weather variables
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _fetchUserCrops();
    _fetchWeather();
  }

  Future<void> _fetchUserCrops() async {
    setState(() {
      _isLoadingCrops = true;
      _fetchError = null;
    });
    try {
      if (userId == null) {
        throw Exception('No user is currently authenticated');
      }

      QuerySnapshot cropSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('crops')
          .get();

      List<Map<String, dynamic>> userCrops = [];

      for (var doc in cropSnapshot.docs) {
        var cropData = doc.data() as Map<String, dynamic>;
        QuerySnapshot cropDetailSnapshot = await FirebaseFirestore.instance
            .collection('crops')
            .where('name', isEqualTo: cropData['CropName'])
            .limit(1)
            .get();

        if (cropDetailSnapshot.docs.isNotEmpty) {
          var cropDetails =
          cropDetailSnapshot.docs.first.data() as Map<String, dynamic>;
          cropData['harvestDays'] = cropDetails['harvestDateNumber'] ?? 0;
          cropData['bestPlantingSeason'] =
              cropDetails['bestPlantingSeason'] ?? '';
          cropData['fertilizers'] = cropDetails['fertilizers'] ?? '';
          cropData['growingTime'] = cropDetails['growingTime'] ?? 0;
          cropData['irrigationGuide'] = cropDetails['irrigationGuide'] ?? '';
          cropData['soilType'] = cropDetails['soilType'] ?? '';
          cropData['sunlight'] = cropDetails['sunlight'] ?? '';
          cropData['type'] = cropDetails['type'] ?? '';
          cropData['waterRequirement'] = cropDetails['waterRequirement'] ?? '';
        }
        userCrops.add(cropData);
      }

      setState(() {
        _userCrops = userCrops.map((crop) => CropData.fromMap(crop)).toList();
        _isLoadingCrops = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCrops = false;
        _fetchError = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching crops: $_fetchError')),
      );

      if (e.toString().contains('authenticated')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
                (route) => false,
          );
        });
      }
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });
    try {
      final weatherData = await WeatherService.getCurrentWeather();
      setState(() {
        _weatherData = weatherData;
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWeather = false;
        _weatherError = e.toString();
        print("Weather error: $e"); // Add logging to see the full error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error fetching weather data. Please check location permissions.'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _fetchWeather();
            },
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchWeather();
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh weather data',
      ),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weather Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_isLoadingWeather)
              const Center(child: CircularProgressIndicator(color: Colors.green))
            else if (_weatherError != null)
              GestureDetector(
                onTap: () {
                  _fetchWeather();
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Weather data unavailable',
                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please enable location services and grant permissions. Tap to retry.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
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
                      value: _weatherData?['main']?['temp']?.toStringAsFixed(1) ??
                          'N/A',
                      label: 'Temperature (°C)',
                      iconColor: Colors.orange),
                  CardWeatherTile(
                      icon: Icons.cloud,
                      value: _weatherData?['rain']?['3h']?.toString() ?? '0',
                      label: 'Precipitation (mm)',
                      iconColor: Colors.blue),
                  CardWeatherTile(
                      icon: Icons.opacity,
                      value: _weatherData?['main']?['humidity']?.toString() ??
                          'N/A',
                      label: 'Humidity (%)',
                      iconColor: Colors.blue),
                  CardWeatherTile(
                      icon: Icons.air,
                      value: _weatherData?['wind']?['speed']?.toStringAsFixed(1) ??
                          'N/A',
                      label: 'Wind (m/s)',
                      iconColor: Colors.grey),
                  CardWeatherTile(
                      icon: Icons.terrain,
                      value: 'N/A', // Soil moisture not directly available
                      label: 'Soil Moisture',
                      iconColor: Colors.brown),
                  CardWeatherTile(
                      icon: Icons.ac_unit,
                      value: _weatherData?['wind']?['gust']?.toStringAsFixed(1) ??
                          'N/A',
                      label: 'Wind Gust (m/s)',
                      iconColor: Colors.green),
                ],
              ),
            const SizedBox(height: 20),
            Text('Your Crops',
                style: GoogleFonts.adamina(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_isLoadingCrops)
              const Center(
                  child: CircularProgressIndicator(color: Colors.green))
            else if (_fetchError != null)
              Center(
                  child: Text('Error: $_fetchError',
                      style: const TextStyle(color: Colors.red, fontSize: 16)))
            else if (_userCrops.isEmpty)
                const Center(child: Text('No crops found'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _userCrops.length,
                  itemBuilder: (context, index) {
                    final crop = _userCrops[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crop.name,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text("Type: ${crop.type}"),
                                Text(
                                    "Planted on: ${_formatDate(crop.plantDate)}"),
                                Text(
                                    "Harvest on: ${_formatDate(crop.harvestDate)}"),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CropDetails(
                                    userId: userId!,
                                    crop: crop,
                                  ),
                                ),
                              );
                            },
                            child: const Icon(Icons.menu, size: 30),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}