import 'package:farm_wise/Common/Constant.dart';
import 'package:flutter/material.dart';

Widget buildInfoRow(IconData icon, String label, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: KTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: KTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}