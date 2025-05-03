import 'package:farm_wise/Common/Constant.dart'; // Assuming you want to use the same styling constants
import 'package:flutter/material.dart';

class IrrigationCrop extends StatelessWidget {
  final String irrigationcrop;
  final String waterRequirement;

  const IrrigationCrop({
    super.key,
    required this.irrigationcrop,
    required this.waterRequirement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$irrigationcrop requires ${waterRequirement.toLowerCase()} water for optimal growth.',
          style: KTextStyle, // Using your app's consistent text style
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 8), // Adding some spacing
        Row(
          children: [
            const Icon(Icons.water_drop, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Water Requirement: $waterRequirement',
              style: KTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}