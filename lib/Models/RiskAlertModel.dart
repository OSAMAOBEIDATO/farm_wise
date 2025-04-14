import 'package:cloud_firestore/cloud_firestore.dart';

class RiskAlertModel {
  final String alertId;
  final String userId;
  final String riskType;
  final String description;
  final String riskLevel;

  RiskAlertModel({
    required this.alertId,
    required this.userId,
    required this.riskType,
    required this.description,
    required this.riskLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'riskType': riskType,
      'description': description,
      'riskLevel': riskLevel,
    };
  }

  factory RiskAlertModel.fromMap(String alertId, Map<String, dynamic> map) {
    return RiskAlertModel(
      alertId: alertId,
      userId: map['userId'] ?? '',
      riskType: map['riskType'] ?? '',
      description: map['description'] ?? '',
      riskLevel: map['riskLevel'] ?? '',
    );
  }
}
