import 'package:cloud_firestore/cloud_firestore.dart';

class CropData {
  final String cropId;
  final String userId;
  final String cropName;
  final DateTime harvestDate;
  final DateTime plantDate;
  final String plantType;
  final List<dynamic> fertilizers;
  final List<dynamic> pesticides;
  final DateTime createdAt; // Add createdAt field

  CropData({
    required this.cropId,
    required this.userId,
    required this.cropName,
    required this.harvestDate,
    required this.plantDate,
    required this.plantType,
    required this.fertilizers,
    required this.pesticides,
    required this.createdAt,
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
      'createdAt': createdAt, // Include in map
    };
  }

  factory CropData.fromMap(String cropId, Map<String, dynamic> map) {
    return CropData(
      cropId: cropId,
      userId: map['userId'] ?? '',
      cropName: map['cropName'] ?? '',
      harvestDate: (map['harvestDate'] as Timestamp).toDate(),
      plantDate: (map['plantDate'] as Timestamp).toDate(),
      plantType: map['plantType'] ?? '',
      fertilizers: List<String>.from(map['fertilizers'] ?? []),
      pesticides: List<String>.from(map['pesticides'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // Add createdAt
    );
  }
}