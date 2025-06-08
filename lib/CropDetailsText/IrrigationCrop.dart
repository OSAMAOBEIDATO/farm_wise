import 'package:farm_wise/Common/Constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IrrigationCrop extends StatelessWidget {
  final String irrigationcrop;
  final String waterRequirement;

  const IrrigationCrop({
    super.key,
    required this.irrigationcrop,
    required this.waterRequirement,
  });

  Color _getWaterLevelColor(String requirement) {
    switch (requirement.toLowerCase()) {
      case 'high':
        return Colors.blue[700]!;
      case 'medium':
        return Colors.blue[500]!;
      case 'low':
        return Colors.blue[300]!;
      default:
        return Colors.blue[500]!;
    }
  }

  IconData _getWaterIcon(String requirement) {
    switch (requirement.toLowerCase()) {
      case 'high':
        return Icons.water_drop;
      case 'medium':
        return Icons.water_drop_outlined;
      case 'low':
        return Icons.opacity;
      default:
        return Icons.water_drop_outlined;
    }
  }

  Widget _buildWaterLevelIndicator() {
    final color = _getWaterLevelColor(waterRequirement);
    final icon = _getWaterIcon(waterRequirement);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Water Requirement',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                waterRequirement.toUpperCase(),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main description
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '$irrigationcrop requires ${waterRequirement.toLowerCase()} water for optimal growth and healthy development.',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Water requirement indicator
        _buildWaterLevelIndicator(),

        // Irrigation tips
      ],
    );
  }
}