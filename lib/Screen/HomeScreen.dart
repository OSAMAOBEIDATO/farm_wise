import 'package:farm_wise/Models/CropUser.dart';
import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_wise/Screen/LoginScreen.dart';
import 'package:farm_wise/components/CardWeatherTile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Crop> _userCrops = [];
  bool _isLoadingCrops = true;
  String? _fetchError;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserCrops();
  }

  Future<void> _fetchUserCrops() async {
    setState(() {
      _isLoadingCrops = true;
      _fetchError = null;
    });

    try {
      _userId = FirebaseAuth.instance.currentUser?.uid;
      if (_userId == null)
        throw Exception('No user is currently authenticated');

      QuerySnapshot cropSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
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
          cropData['harvestDays'] = cropDetails['harvestDate'] ?? 0;
        } else {
          cropData['harvestDays'] = 0;
        }

        userCrops.add(cropData);
      }

      setState(() {
        _userCrops = userCrops.map((crop) => Crop.fromMap(crop)).toList();
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
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weather Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    iconColor: Colors.orange),
                CardWeatherTile(
                    icon: Icons.cloud,
                    value: '10%',
                    label: 'Precipitation',
                    iconColor: Colors.blue),
                CardWeatherTile(
                    icon: Icons.opacity,
                    value: '61%',
                    label: 'Humidity',
                    iconColor: Colors.blue),
                CardWeatherTile(
                    icon: Icons.air,
                    value: '5 km/h',
                    label: 'Wind',
                    iconColor: Colors.grey),
                CardWeatherTile(
                    icon: Icons.terrain,
                    value: '24.5%',
                    label: 'Soil moisture',
                    iconColor: Colors.brown),
                CardWeatherTile(
                    icon: Icons.check_circle,
                    value: 'Healthy',
                    label: 'Crop Health',
                    iconColor: Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Your Crops',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      // space between text and icon
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop.cropName,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text("Type: ${crop.plantType}"),
                              Text("Planted on: ${crop.plantDate}"),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CropDetails()));
                          },
                          child: const Icon(Icons.menu, size: 30),
                        )
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
