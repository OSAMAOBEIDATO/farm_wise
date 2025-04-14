import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/service/Authentication.dart';

class CropService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authServices = AuthService();

  Future<String> addCrop(CropData crop) async {
    try {
      final String? userId = _authServices.getCurrentUserId();
      if (userId == null) {
        return 'User not authenticated';
      }
      final cropData = crop.toMap();
      cropData['userId'] = userId;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('crops')
          .add(cropData);
      return "Successfully";
    } catch (e) {
      return 'Error adding Crop:$e';
    }
  }

  Future<List<CropData>> getCrops() async {
    try {
      final String? userId = _authServices.getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('crops')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CropData.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching crops: $e');
      return [];
    }
  }
}
