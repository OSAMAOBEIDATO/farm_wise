import 'package:farm_wise/Common/Constant.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class WeatherService {
  static const String _apiKey = open_Waether_APA_Key ;

  static Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'Location services are disabled. Please enable them in settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied. Please enable them in app settings.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  static Future<Map<String, dynamic>> getCurrentWeather() async {
    if (_apiKey.isEmpty) {
      throw Exception('Weather API key not found.');
    }

    try {
      final position = await _getCurrentLocation();
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?'
              'lat=${position.latitude}&lon=${position.longitude}'
              '&appid=$_apiKey&units=metric'
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load weather data: ${response.statusCode} - ${response
                .body}');
      }
    } catch (e) {
      throw Exception('Weather fetch failed: $e');
    }
  }
}
