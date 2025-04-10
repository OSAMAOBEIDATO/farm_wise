import 'package:cloud_firestore/cloud_firestore.dart';

class CropModel {
  final String cropId;
  final String userId;
  final String cropName;
  final DateTime harvestDate;
  final DateTime plantDate;
  final String plantType;
  final List<String> fertilizers;
  final List<String> pesticides;

  CropModel({
    required this.cropId,
    required this.userId,
    required this.cropName,
    required this.harvestDate,
    required this.plantDate,
    required this.plantType,
    required this.fertilizers,
    required this.pesticides,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cropName': cropName,
      'harvestDate': harvestDate,
      'plantDate': plantDate,
      'plantType': plantType,
      'fertilizers': fertilizers,
      'pesticides': pesticides,
    };
  }

  factory CropModel.fromMap(String cropId, Map<String, dynamic> map) {
    return CropModel(
      cropId: cropId,
      userId: map['userId'] ?? '',
      cropName: map['cropName'] ?? '',
      harvestDate: (map['harvestDate'] as Timestamp).toDate(),
      plantDate: (map['plantDate'] as Timestamp).toDate(),
      plantType: map['plantType'] ?? '',
      fertilizers: List<String>.from(map['fertilizers'] ?? []),
      pesticides: List<String>.from(map['pesticides'] ?? []),
    );
  }
}