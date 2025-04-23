import 'package:cloud_firestore/cloud_firestore.dart';

class Crop {
  final String cropName;
  final String plantDate;
  final String plantType;
  final int harvestDays;

  Crop({
    required this.cropName,
    required this.plantDate,
    required this.plantType,
    required this.harvestDays,
  });

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      cropName: map['CropName'] ?? 'Unknown',
      plantDate: map['PlantDate'] ?? 'Unknown',
      plantType: map['PlantType'] ?? 'Unknown',
      harvestDays: map['harvestDays'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'CropName': cropName,
      'PlantDate': plantDate,
      'PlantType': plantType,
      'harvestDays': harvestDays,
    };
  }
}