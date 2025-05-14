import 'dart:convert';
import 'package:farm_wise/Common/Constant.dart';
import 'package:http/http.dart' as http;
import 'package:weather/weather.dart';

class WeatherService {



}





// class WeatherService {
//   static const String _apiKey = 'your_api_key'; // Replace with your OpenWeatherMap API key
//   static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
//
//   Future<Position> _getUserLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled.');
//     }
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Location permissions are denied.');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       throw Exception('Location permissions are permanently denied.');
//     }
//
//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }

//   Future<WeatherData> fetchWeatherData() async {
//     try {
//       Position position = await _getUserLocation();
//       double lat = position.latitude;
//       double lon = position.longitude;
//
//       final response = await http.get(
//         Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         double temperature = data['main']['temp'];
//         double humidity = data['main']['humidity'].toDouble();
//         double windSpeed = data['wind']['speed'].toDouble();
//         double precipitation = data['rain'] != null && data['rain']['1h'] != null
//             ? data['rain']['1h'].toDouble()
//             : 0.0;
//
//         return WeatherData(
//           temperature: temperature,
//           precipitation: precipitation,
//           humidity: humidity,
//           windSpeed: windSpeed,
//         );
//       } else {
//         throw Exception('Failed to load weather data: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching weather data: $e');
//     }
//   }
// }
