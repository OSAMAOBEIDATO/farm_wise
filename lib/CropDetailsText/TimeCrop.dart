import 'package:farm_wise/Common/Constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class TimeCrop extends StatelessWidget {
  final String bestPlantingSeason;
  final int growingTime;
  final int harvestDateNumber;
  final DateTime? harvestDate;
  final DateTime? plantDate;
  final String cropName;

  const TimeCrop({
    super.key,
    required this.growingTime,
    required this.harvestDateNumber,
    required this.harvestDate,
    required this.plantDate,
    required this.bestPlantingSeason,
    required this.cropName,
  });

  // Format dates properly or display "Not set" if null
  String _formatDate(DateTime? date) {
    if (date == null) return "Not set";
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$cropName is typically grown during the $bestPlantingSeason season. '
              'It was planted on ${_formatDate(plantDate)} and usually takes around $growingTime days to mature. '
              'The expected harvest date is ${_formatDate(harvestDate)}.',
          style: KTextStyle,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}