import 'package:farm_wise/Components/HomeScreenComponent/CropCardHomeScreen.dart';
import 'package:farm_wise/Components/HomeScreenComponent/CropsSectionHomeScreen.dart';
import 'package:farm_wise/Components/HomeScreenComponent/HeaderHomeScreen.dart';
import 'package:farm_wise/Components/HomeScreenComponent/WeatherSection.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:farm_wise/service/WeatherService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<CropData> _userCrops = [];
  bool _isLoadingCrops = true;
  bool _isLoadingWeather = true;
  String? _fetchError;
  Map<String, dynamic>? _weather;
  List<Map<String, dynamic>> userCropsData = [];
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchUserCrops();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoadingWeather = true;
    });

    try {
      final weather = await WeatherService.getCurrentWeather();
      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      print('Error fetching weather: $e');
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
        _showErrorSnackBar('Unable to fetch weather data: ${e.toString()}');
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
          _userCrops =
              userCropsData.map((crop) => CropData.fromMap(crop)).toList();
          _isLoadingCrops = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCrops = false;
          _fetchError = e.toString();
        });
        _showErrorSnackBar('Error loading crops: ${e.toString()}');
      }
    }
  }



  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _fetchUserCrops(),
      _fetchWeather(),
    ]);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return "${date.day}/${date.month}/${date.year}";
  }

  int _getDaysUntilHarvest(DateTime? harvestDate) {
    if (harvestDate == null) return 0;
    return harvestDate.difference(DateTime.now()).inDays;
  }

  void _navigateToCropDetails(CropData crop) {
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
      _showErrorSnackBar('User not authenticated. Cannot view crop details.');
    }
  }

  Widget _buildCropCard(CropData crop) {
    return CropCardHomeScreen(
      crop: crop,
      daysUntilHarvest: _getDaysUntilHarvest(crop.harvestDate),
      onTap: () => _navigateToCropDetails(crop),
      formatDate: _formatDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderForHomeScreen(refreshData: _refreshData),
              const SizedBox(height: 24),
              WeatherSection(
                isLoading: _isLoadingWeather,
                weather: _weather,
                onRetry: _fetchWeather,
              ),
              const SizedBox(height: 32),
              CropsSection(
                userCrops: _userCrops,
                isLoadingCrops: _isLoadingCrops,
                fetchError: _fetchError,
                onRetry: _refreshData,
                buildCropCard: _buildCropCard,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}