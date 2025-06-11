import 'dart:io';
import 'package:farm_wise/Components/_buildInfoRowDis.dart';
import 'package:farm_wise/service/ImagePickerService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CropDiseaseDetectionScreen extends StatefulWidget {
  const CropDiseaseDetectionScreen({super.key});

  @override
  _CropDiseaseDetectionScreenState createState() => _CropDiseaseDetectionScreenState();
}

class _CropDiseaseDetectionScreenState extends State<CropDiseaseDetectionScreen> {
  File? _image;
  String? _diseaseName;
  double? _confidence;
  String? _cureTreatment;
  String? _fertilizerRecommendation;
  String? _irrigationGuidelines;
  String? _additionalInfo;
  String? _error;
  bool _isLoading = false;

  final ImagePickerService _imagePickerService = ImagePickerServiceImpl();
  final ApiService _apiService = ApiServiceImpl();

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _diseaseName = null;
      _confidence = null;
      _cureTreatment = null;
      _fertilizerRecommendation = null;
      _irrigationGuidelines = null;
      _additionalInfo = null;
    });

    try {
      final pickedFile = await _imagePickerService.pickImageFromGallery();
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _predictDisease();
      } else {
        setState(() {
          _error = 'No image selected.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking image: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _predictDisease() async {
    if (_image == null) {
      setState(() {
        _error = 'No image selected.';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.predictDisease(_image!.path);
      setState(() {
        if (response.containsKey('error')) {
          _error = response['error'];
          _diseaseName = null;
          _confidence = null;
        } else {
          _diseaseName = response['class'];
          _confidence = response['confidence'].toDouble().clamp(0.0, 1.0); // Cap confidence between 0 and 1
          _error = null;
          _fetchDiseaseDetails(_diseaseName!);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to predict disease: $e';
        _diseaseName = null;
        _confidence = null;
        _isLoading = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(_error ?? 'Prediction complete!'),
          ],
        ),
        backgroundColor: _error != null ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _fetchDiseaseDetails(String diseaseName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('diseases')
          .where('DiseaseName', isEqualTo: diseaseName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          _cureTreatment = data['Cure/Treatment'];
          _fertilizerRecommendation = data['Fertilizer Recommendation'];
          _irrigationGuidelines = data['Irrigation Guidelines'];
          _additionalInfo = data['Additional Info'];
        });
      } else {
        setState(() {
          _error = 'No details found for $diseaseName';
          _cureTreatment = 'Not available';
          _fertilizerRecommendation = 'Not available';
          _irrigationGuidelines = 'Not available';
          _additionalInfo = 'Not available';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching details: $e';
        _cureTreatment = 'Not available';
        _fertilizerRecommendation = 'Not available';
        _irrigationGuidelines = 'Not available';
        _additionalInfo = 'Not available';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[100]!, Colors.green[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.biotech,
                      size: 40,
                      color: Colors.green[700],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'AI-Powered Crop Analysis',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Take a photo to detect diseases instantly',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _image == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: Colors.green[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Camera Preview',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Position your crop in the center',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Camera capture not implemented yet.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt, size: 22),
                      label: Text(
                        'Capture Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library, size: 22),
                    label: Text(
                      'Gallery',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.green[700], size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Detection Results',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Text(
                          _error!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else if (_diseaseName != null && _confidence != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.coronavirus,
                                    color: Colors.orange[700],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _diseaseName!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _confidence! > 0.8
                                              ? 'High Severity'
                                              : _confidence! > 0.6
                                              ? 'Moderate Severity'
                                              : 'Low Severity',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.speed, color: Colors.green[600], size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Confidence: ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${(_confidence! * 100).clamp(0, 100).toInt()}%', // Cap at 100%
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _confidence!.clamp(0.0, 1.0), // Cap width factor
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green[400]!, Colors.green[600]!],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_cureTreatment != null)
                              buildInfoRowDis('Treatment', _cureTreatment!),
                            if (_fertilizerRecommendation != null)
                              buildInfoRowDis('Fertilizer', _fertilizerRecommendation!),
                            if (_irrigationGuidelines != null)
                              buildInfoRowDis('Irrigation', _irrigationGuidelines!),
                            if (_additionalInfo != null)
                              buildInfoRowDis('Additional Info', _additionalInfo!),
                            const SizedBox(height: 20),

                          ],
                        )
                      else
                        Text(
                          'No results yet. Select an image to analyze.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
