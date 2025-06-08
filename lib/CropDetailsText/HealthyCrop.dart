import 'package:farm_wise/Common/Constant.dart';
import 'package:farm_wise/Components/buildInfoRow.dart';
import 'package:flutter/material.dart';

class Healthycrop extends StatelessWidget {
  final String soilType;
  final String sunlight;
  final String fertilizers;
  final String irrigationCrop;

  const Healthycrop({
    super.key,
    required this.soilType,
    required this.sunlight,
    required this.fertilizers,
    required this.irrigationCrop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This crop grows effectively in $soilType soil and prefers $sunlight '
              'sunlight to achieve optimal growth. Optimal growth is supported by using $fertilizers fertilizers. ',
          style: KTextStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
        buildInfoRow(Icons.landscape, 'Soil Type', soilType, Colors.brown),
        buildInfoRow(Icons.wb_sunny, 'Sunlight', sunlight, Colors.orange),
        buildInfoRow(Icons.eco, 'Fertilizers', fertilizers, Colors.green),
      ],
    );
  }


}