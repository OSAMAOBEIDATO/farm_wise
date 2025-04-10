import 'package:cloud_firestore/cloud_firestore.dart';

class SoilDataModel {
  final String soilId;
  final String cropId;
  final String location;
  final double soilMoisture;
  final double pHLevel;

  SoilDataModel({
    required this.soilId,
    required this.cropId,
    required this.location,
    required this.soilMoisture,
    required this.pHLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'cropId': cropId,
      'location': location,
      'soilMoisture': soilMoisture,
      'pHLevel': pHLevel,
    };
  }

  factory SoilDataModel.fromMap(String soilId, Map<String, dynamic> map) {
    return SoilDataModel(
      soilId: soilId,
      cropId: map['cropId'] ?? '',
      location: map['location'] ?? '',
      soilMoisture: (map['soilMoisture'] as num).toDouble(),
      pHLevel: (map['pHLevel'] as num).toDouble(),
    );
  }
}