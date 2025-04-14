import 'package:flutter/material.dart';

class CropDiseaseDetectionScreen extends StatelessWidget {
 static const String id = "CropDiseaseDetectionScreen";
  final String userId; // Kept for consistency, but not used

  const CropDiseaseDetectionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Crop Disease Detection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Simulated camera preview area
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Simulated "Take Photo" button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Simulate taking a photo and showing results
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo captured! Processing...')),
                  );
                },
                icon: const Icon(Icons.camera),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Simulated disease detection result
            const Text(
              'Detection Result:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disease: Leaf Blight',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Confidence: 85%',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Recommendation: Apply fungicide and monitor crop.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}