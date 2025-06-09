import 'dart:convert';
import 'dart:io';
import 'package:farm_wise/service/ImagePickerService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CropDiseaseDetectionScreen extends StatefulWidget {
  const CropDiseaseDetectionScreen({super.key});

  @override
  _CropDiseaseDetectionScreenState createState() => _CropDiseaseDetectionScreenState();
}

class _CropDiseaseDetectionScreenState extends State<CropDiseaseDetectionScreen> {
  File? _image;
  String? _diseaseName;
  double? _confidence;
  String? _error;
  bool _isLoading = false;

  // Dependency injection
  final ImagePickerService _imagePickerService = ImagePickerServiceImpl();
  final ApiService _apiService = ApiServiceImpl('http://192.168.1.23:5000/predict'); // http://127.0.0.1:5000/predict   Replace with your Flask server URL

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _diseaseName = null;
      _confidence = null;
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

  // Send image to Flask backend
  Future<void> _predictDisease() async {
    if (_image == null) {
      setState(() {
        _error = 'No image selected.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _apiService.predictDisease(_image!.path);
      setState(() {
        if (response.containsKey('error')) {
          _error = response['error'];
          _diseaseName = null;
          _confidence = null;
        } else {
          _diseaseName = response['class'];
          _confidence = response['confidence'].toDouble();
          _error = null;
        }
        _isLoading = false;
      });

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
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _diseaseName = null;
        _confidence = null;
        _isLoading = false;
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
              // Header section
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

              // Image preview area
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
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Ensure good lighting for best results',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
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

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () {
                        // Camera capture logic (to be implemented)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.camera, color: Colors.white),
                                const SizedBox(width: 10),
                                const Text('Camera capture not implemented yet.'),
                              ],
                            ),
                            backgroundColor: Colors.green[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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

              // Results section header
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

              // Results card
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
                            // Disease name with severity indicator
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

                            // Confidence meter
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
                                  '${(_confidence! * 100).toStringAsFixed(0)}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Confidence bar
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _confidence!,
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

                            // Recommendation (static for now, can be enhanced)
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Recommendation',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Apply copper-based fungicide every 7-10 days. Remove affected leaves and ensure good air circulation around plants.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Action button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to detailed treatment page (to be implemented)
                                },
                                icon: const Icon(Icons.medical_services, size: 20),
                                label: Text(
                                  'View Treatment Details',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
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