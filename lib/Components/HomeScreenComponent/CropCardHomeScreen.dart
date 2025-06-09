import 'package:farm_wise/Models/CropData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropCardHomeScreen extends StatelessWidget {
  final CropData crop;
  final int daysUntilHarvest;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  const CropCardHomeScreen({super.key,
    required this.crop,
    required this.daysUntilHarvest,
    required this.onTap,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final isReadyToHarvest = daysUntilHarvest <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isReadyToHarvest
            ? Border.all(color: Colors.orange, width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/Image/${crop.name}.jpg'),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {},
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Text(""),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            crop.name,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        if (isReadyToHarvest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Ready!',
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          crop.type,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          isReadyToHarvest
                              ? 'Harvest now'
                              : '$daysUntilHarvest days left',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: isReadyToHarvest ? Colors.orange : Colors
                                .grey[600],
                            fontWeight: isReadyToHarvest
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Planted: ${formatDate(crop.plantDate!)}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}