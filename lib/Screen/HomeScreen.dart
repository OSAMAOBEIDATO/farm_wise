import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Components/CardWeatherTile.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CropData> _userCrops = [];
  bool _isLoadingCrops = true;
  String? _fetchError;
  final WeatherFactory _wf = WeatherFactory(open_Waether_APA_Key);
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _fetchUserCrops();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weather = await _wf.currentWeatherByCityName("Irbid");
      if (mounted) {
        setState(() {
          _weather = weather;
        });
      }
    } catch (e) {
      print('Error fetching weather: $e');
      // Optionally show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching weather: $e')),
        );
      }
    }
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

      List<Map<String, dynamic>> userCropsData = [];

      for (var doc in cropSnapshot.docs) {
        var cropData = doc.data() as Map<String, dynamic>;
        cropData['CropID'] = doc.id;

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
          cropData['PlantType'] = cropDetails['type'] ?? '';
          cropData['waterRequirement'] = cropDetails['waterRequirement'] ?? '';
        }
        userCropsData.add(cropData);
      }

      if (mounted) {
        setState(() {
          _userCrops = userCropsData.map((crop) => CropData.fromMap(crop)).toList();
          _isLoadingCrops = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCrops = false;
          _fetchError = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching crops: $_fetchError')),
        );
      }
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
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

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
                  value: _weather!.temperature?.celsius?.toStringAsFixed(1) ?? 'N/A',
                  label: 'Temperature (°C)',
                  iconColor: Colors.orange,
                ),
                CardWeatherTile(
                  icon: Icons.cloud,
                  value: _weather!.rainLast3Hours?.toStringAsFixed(1) ?? '0',
                  label: 'Precipitation (mm)',
                  iconColor: Colors.blue,
                ),
                CardWeatherTile(
                  icon: Icons.opacity,
                  value: _weather!.humidity?.toStringAsFixed(0) ?? 'N/A',
                  label: 'Humidity (%)',
                  iconColor: Colors.blue,
                ),
                CardWeatherTile(
                  icon: Icons.air,
                  value: _weather!.windSpeed?.toStringAsFixed(1) ?? 'N/A',
                  label: 'Wind (m/s)',
                  iconColor: Colors.grey,
                ),
                CardWeatherTile(
                  icon: Icons.terrain,
                  value: _weather!.tempMax.toString(),
                  label: 'Soil Moisture',
                  iconColor: Colors.brown,
                ),
                CardWeatherTile(
                  icon: Icons.ac_unit,
                  value: '${_weather!.windGust?.toStringAsFixed(1) ?? 'N/A'}',
                  label: 'Wind Gust (m/s)',
                  iconColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Your Crops',
              style: GoogleFonts.adamina(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoadingCrops)
              const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            else if (_fetchError != null)
              Center(
                child: Text(
                  'Error: $_fetchError',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text("Type: ${crop.type}"),
                                Text("Planted on: ${_formatDate(crop.plantDate)}"),
                                Text("Harvest on: ${_formatDate(crop.harvestDate)}"),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (userId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CropDetails(
                                      userId: userId!,
                                      crop: crop,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User not authenticated. Cannot view crop details.'),
                                  ),
                                );
                              }
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