import 'package:farm_wise/Components/HomeScreenComponent/EmptyStateForHomeScreen.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropsSection extends StatelessWidget {

  const CropsSection({
    required this.userCrops,
    required this.isLoadingCrops,
    required this.fetchError,
    required this.onRetry,
    required this.buildCropCard,
  });


  final List<CropData> userCrops;
  final bool isLoadingCrops;
  final String? fetchError;
  final VoidCallback onRetry;
  final Widget Function(CropData) buildCropCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.agriculture, color: Colors.green[600], size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Crops',
                  style: GoogleFonts.adamina(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            if (userCrops.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${userCrops.length} crop${userCrops.length != 1 ? 's' : ''}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoadingCrops)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Colors.green),
            ),
          )
        else if (userCrops.isEmpty)
            const EmptyStateForHomeScreen(
              title: 'No crops yet',
              description: 'Start your farming journey by adding your first crop!',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userCrops.length,
              itemBuilder: (context, index) {
                final crop = userCrops[index];
                return buildCropCard(crop);
              },
            ),
      ],
    );
  }
}