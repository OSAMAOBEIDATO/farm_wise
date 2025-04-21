import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class CropData {
  final String cropId;
  final String userId;
  final String cropName;
  final DateTime harvestDate;
  final DateTime plantDate;
  final String soilType;
  final List<dynamic> fertilizers;
  final List<dynamic> pesticides;
  final String? imageUrl; // Make imageUrl optional
  final DateTime createdAt;

  CropData({
    required this.cropId,
    required this.userId,
    required this.cropName,
    //required this Grwing Time  TODO
    required this.harvestDate,
    required this.plantDate,
    required this.soilType,
    required this.fertilizers,
    required this.pesticides,
    required this.createdAt,
    this.imageUrl, // Not required
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cropName': cropName,
      'harvestDate': harvestDate,
      'plantDate': plantDate,
      'plantType': soilType,
      'fertilizers': fertilizers,
      'pesticides': pesticides,
      'createdAt': createdAt,
      'imageUrl': imageUrl, // Include imageUrl
    };
  }

  factory CropData.fromMap(String cropId, Map<String, dynamic> map) {
    return CropData(
      cropId: cropId,
      userId: map['userId'] ?? '',
      cropName: map['cropName'] ?? '',
      harvestDate: (map['harvestDate'] as Timestamp).toDate(),
      plantDate: (map['plantDate'] as Timestamp).toDate(),
      soilType: map['plantType'] ?? '',
      fertilizers: List<String>.from(map['fertilizers'] ?? []),
      pesticides: List<String>.from(map['pesticides'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'] as String?, // Parse imageUrl
    );
  }
}