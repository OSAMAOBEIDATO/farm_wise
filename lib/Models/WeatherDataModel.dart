import 'package:cloud_firestore/cloud_firestore.dart';

class WeatherDataModel {
  final String weatherId;
  final String userId;
  final double precipitation;
  final double maxTemp;
  final double minTemp;
  final double humidity;
  final DateTime sunrise;
  final DateTime sunset;
  final String location;
  final double windSpeed;
  final double windDirection;
  final double cloudCoverage;
  final double uvIndex;

  WeatherDataModel({
    required this.weatherId,
    required this.userId,
    required this.precipitation,
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
    required this.sunrise,
    required this.sunset,
    required this.location,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudCoverage,
    required this.uvIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'precipitation': precipitation,
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'humidity': humidity,
      'sunrise': sunrise,
      'sunset': sunset,
      'location': location,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'cloudCoverage': cloudCoverage,
      'uvIndex': uvIndex,
    };
  }

  factory WeatherDataModel.fromMap(String weatherId, Map<String, dynamic> map) {
    return WeatherDataModel(
      weatherId: weatherId,
      userId: map['userId'] ?? '',
      precipitation: (map['precipitation'] as num).toDouble(),
      maxTemp: (map['maxTemp'] as num).toDouble(),
      minTemp: (map['minTemp'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      sunrise: (map['sunrise'] as Timestamp).toDate(),
      sunset: (map['sunset'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      windSpeed: (map['windSpeed'] as num).toDouble(),
      windDirection: (map['windDirection'] as num).toDouble(),
      cloudCoverage: (map['cloudCoverage'] as num).toDouble(),
      uvIndex: (map['uvIndex'] as num).toDouble(),
    );
  }
}