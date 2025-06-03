import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class WeatherService {
  // Fixed: Use proper environment variable name
  static final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? 'e17ba09f185f38d08bb221a2a8997fe5';

  static Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them in settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10), // Add timeout to prevent hanging
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
      ).timeout(Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Weather fetch failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getWeatherForecast({int days = 5}) async {
    if (_apiKey.isEmpty) {
      throw Exception('Weather API key not found.');
    }

    if (days < 1 || days > 7) {
      throw ArgumentError('Forecast days must be between 1 and 7');
    }

    try {
      final position = await _getCurrentLocation();
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?'
              'lat=${position.latitude}&lon=${position.longitude}'
              '&appid=$_apiKey&units=metric&cnt=${days * 8}'
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Forecast fetch failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    if (_apiKey.isEmpty) {
      throw Exception('Weather API key not found.');
    }

    try {
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?'
              'q=$city&appid=$_apiKey&units=metric'
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('City weather fetch failed: $e');
    }
  }
}