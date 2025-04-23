import 'package:farm_wise/Models/CropUser.dart';
import 'package:flutter/material.dart';

class CardCropTile extends StatelessWidget {
  final Crop crop;
  final Color iconColor;

  const CardCropTile({
    super.key,
    required this.crop,
    required this.iconColor,
  });

  String _calculateHarvestDate() {
    try {
      // Parse PlantDate (format: "DD/MM/YYYY")
      List<String> dateParts = crop.plantDate.split('/');
      DateTime plantDateTime = DateTime(
        int.parse(dateParts[2]), // Year
        int.parse(dateParts[1]), // Month
        int.parse(dateParts[0]), // Day
      );
      DateTime harvestDateTime = plantDateTime.add(Duration(days: crop.harvestDays));
      return '${harvestDateTime.day}/${harvestDateTime.month}/${harvestDateTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist,
              color: iconColor,
              size: 30,
            ),
            const SizedBox(height: 5),
            Text(
              crop.cropName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Planted: ${crop.plantDate}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              'Harvest: ${_calculateHarvestDate()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              crop.plantType,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}