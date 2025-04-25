import 'package:cloud_firestore/cloud_firestore.dart';

class CropData {
  final String cropId;
  final String name;
  final String bestPlantingSeason;
  final String fertilizers;
  final int growingTime; // in days
  final int harvestDateNumber; // in days
  final String irrigationGuide;
  final String soilType;
  final String sunlight;
  final String type;
  final String waterRequirement;
  final DateTime? harvestDate;
  final DateTime? plantDate;

  CropData({
    required this.cropId,
    required this.name,
    required this.bestPlantingSeason,
    required this.fertilizers,
    required this.growingTime,
    required this.harvestDateNumber,
    required this.irrigationGuide,
    required this.soilType,
    required this.sunlight,
    required this.type,
    required this.waterRequirement,
    required this.harvestDate,
    required this.plantDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bestPlantingSeason': bestPlantingSeason,
      'fertilizers': fertilizers,
      'growingTime': growingTime,
      'harvestDateNumber': harvestDateNumber,
      'irrigationGuide': irrigationGuide,
      'soilType': soilType,
      'sunlight': sunlight,
      'type': type,
      'waterRequirement': waterRequirement,
      'HarvestDate': harvestDate != null ? Timestamp.fromDate(harvestDate!) : null,
      'PlantDate': plantDate != null ? Timestamp.fromDate(plantDate!) : null,
    };
  }

  factory CropData.fromMap(Map<String, dynamic> map) {
    return CropData(
      cropId: map['CropID'] ?? '',
      name: map['CropName'] ?? '',
      bestPlantingSeason: map['bestPlantingSeason'] ?? '',
      fertilizers: map['fertilizers'] is Iterable
          ? (map['fertilizers'] as Iterable).join(', ')
          : map['fertilizers']?.toString() ?? '',
      growingTime: map['growingTime'] ?? 0,
      harvestDateNumber: map['harvestDays'] ?? 0,
      irrigationGuide: map['irrigationGuide'] ?? '',
      soilType: map['soilType'] ?? '',
      sunlight: map['sunlight'] ?? '',
      type: map['PlantType'] ?? '',
      waterRequirement: map['waterRequirement'] ?? '',
      harvestDate: map['HarvestDate'] != null
          ? (map['HarvestDate'] as Timestamp).toDate()
          : null,
      plantDate: map['PlantDate'] != null
          ? (map['PlantDate'] as Timestamp).toDate()
          : null,
    );
  }
}