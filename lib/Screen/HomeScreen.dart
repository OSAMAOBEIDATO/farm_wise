import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Components/CardWeatherTile.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:farm_wise/service/WeatherService.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  List<CropData> _userCrops = [];
  bool _isLoadingCrops = true;
  bool _isLoadingWeather = true;
  String? _fetchError;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Map<String, dynamic>? _weather;

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

  Widget _buildGreetingHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    Color greetingColor;

    if (hour < 12) {
      greeting = 'Good Morning!';
      greetingIcon = Icons.wb_sunny;
      greetingColor = Colors.orange;
    } else if (hour < 17) {
      greeting = 'Good Afternoon!';
      greetingIcon = Icons.wb_sunny_outlined;
      greetingColor = Colors.amber;
    } else {
      greeting = 'Good Evening!';
      greetingIcon = Icons.nights_stay;
      greetingColor = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(greetingIcon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome to FarmWise',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            tooltip: 'Refresh data',
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.wb_cloudy, color: Colors.blue[600], size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Weather Today',
              style: GoogleFonts.adamina(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingWeather)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Colors.green),
            ),
          )
        else if (_weather == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Unable to load weather data',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildEnhancedWeatherCard(
                icon: Icons.wb_sunny,
                value: '${_weather!['main']['temp']?.toStringAsFixed(1)}°C',
                label: 'Temperature',
                iconColor: Colors.orange,
                subtitle: 'Feels like ${_weather!['main']['feels_like']?.toStringAsFixed(0)}°C',
              ),
              _buildEnhancedWeatherCard(
                icon: Icons.opacity,
                value: '${_weather!['main']['humidity']}%',
                label: 'Humidity',
                iconColor: Colors.blue,
                subtitle: _getHumidityStatus(_weather!['main']['humidity'] ?? 0),
              ),
              _buildEnhancedWeatherCard(
                icon: Icons.air,
                value: '${_weather!['wind']['speed']?.toStringAsFixed(1)} m/s',
                label: 'Wind Speed',
                iconColor: Colors.grey,
                subtitle: _getWindStatus(_weather!['wind']['speed']?.toDouble() ?? 0.0),
              ),
              _buildEnhancedWeatherCard(
                icon: Icons.cloud,
                value: '${(_weather!['rain']?['3h'] ?? 0).toStringAsFixed(1)} mm',
                label: 'Precipitation',
                iconColor: Colors.indigo,
                subtitle: 'Last 3 hours',
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEnhancedWeatherCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.roboto(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getHumidityStatus(int humidity) {
    if (humidity < 30) return 'Very Dry';
    if (humidity < 50) return 'Dry';
    if (humidity < 70) return 'Comfortable';
    if (humidity < 85) return 'Humid';
    return 'Very Humid';
  }

  String _getWindStatus(double windSpeed) {
    if (windSpeed < 1) return 'Calm';
    if (windSpeed < 5) return 'Light breeze';
    if (windSpeed < 10) return 'Moderate breeze';
    if (windSpeed < 15) return 'Strong breeze';
    return 'Very windy';
  }

  Widget _buildCropsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.agriculture, color: Colors.green[600], size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Crops',
                  style: GoogleFonts.adamina(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            if (_userCrops.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_userCrops.length} crop${_userCrops.length != 1 ? 's' : ''}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingCrops)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Colors.green),
            ),
          )
        else if (_fetchError != null)
          _buildErrorCard('Error loading crops', _fetchError!)
        else if (_userCrops.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userCrops.length,
              itemBuilder: (context, index) {
                final crop = _userCrops[index];
                return _buildCropCard(crop);
              },
            ),
      ],
    );
  }

  Widget _buildCropCard(CropData crop) {
    final daysUntilHarvest = _getDaysUntilHarvest(crop.harvestDate);
    final isReadyToHarvest = daysUntilHarvest <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isReadyToHarvest
            ? Border.all(color: Colors.orange, width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => _navigateToCropDetails(crop),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/Image/${crop.name}.jpg'),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {},
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: Text(""),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            crop.name,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        if (isReadyToHarvest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Ready!',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          crop.type,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          isReadyToHarvest
                              ? 'Harvest now'
                              : '$daysUntilHarvest days left',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: isReadyToHarvest ? Colors.orange : Colors.grey[600],
                            fontWeight: isReadyToHarvest ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Planted: ${_formatDate(crop.plantDate)}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String title, String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.agriculture,
              size: 48,
              color: Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No crops yet',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your farming journey by adding your first crop!',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
              _buildGreetingHeader(),
              const SizedBox(height: 24),
              _buildWeatherSection(),
              const SizedBox(height: 32),
              _buildCropsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}