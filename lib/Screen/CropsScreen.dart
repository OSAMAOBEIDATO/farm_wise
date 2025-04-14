import 'package:flutter/material.dart';

// Simplified Crop model for display only
class Crop {
  final String id;
  final String cropName;
  final String plantingDate;
  final String harvestDate;

  Crop({
    required this.id,
    required this.cropName,
    required this.plantingDate,
    required this.harvestDate,
  });
}

class CropsScreen extends StatelessWidget {
  static const String id = "CropScreen";
  final String userId; // Kept for consistency, but not used

   CropsScreen({super.key, required this.userId});

  // Hardcoded list of crops for display
  final List<Crop> _crops = [
    Crop(
      id: '1',
      cropName: 'Corn',
      plantingDate: '2025-03-01',
      harvestDate: '2025-06-01',
    ),
     Crop(
      id: '2',
      cropName: 'Wheat',
      plantingDate: '2025-04-01',
      harvestDate: '2025-07-01',
    ),
     Crop(
      id: '3',
      cropName: 'Barley',
      plantingDate: '2025-05-01',
      harvestDate: '2025-08-01',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _crops.isEmpty
            ? const Center(child: Text('No crops available.'))
            : ListView.builder(
          itemCount: _crops.length,
          itemBuilder: (context, index) {
            final crop = _crops[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.local_florist, color: Colors.green),
                title: Text(crop.cropName),
                subtitle: Text(
                  'Planted: ${crop.plantingDate} | Harvest: ${crop.harvestDate}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}