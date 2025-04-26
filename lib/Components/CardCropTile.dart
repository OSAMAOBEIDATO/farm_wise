import 'package:farm_wise/models/CropData.dart';
import 'package:flutter/material.dart';

class CardCropTile extends StatelessWidget {
  final CropData crop;
  final Color iconColor;

  const CardCropTile({
    super.key,
    required this.crop,
    required this.iconColor,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
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
              crop.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Planted: ${_formatDate(crop.plantDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              'Harvest: ${_formatDate(crop.harvestDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              crop.soilType,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}