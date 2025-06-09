import 'package:farm_wise/Components/CropDetailsComponent/TapContectDetails.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentAreaCropDetails extends StatelessWidget {
  const ContentAreaCropDetails({
    super.key,
    required this.fadeAnimation,
    required this.activeTab,
    required this.crop,
    required this.tabIconBuilder,
    required this.tabTitleBuilder,
  });

  final Animation<double> fadeAnimation;
  final CropDetailTab activeTab;
  final CropData crop;
  final IconData Function(CropDetailTab) tabIconBuilder;
  final String Function(CropDetailTab) tabTitleBuilder;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabHeader(),
            const SizedBox(height: 20),
            TabContentCropDetails(
              activeTab: activeTab,
              crop: crop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            tabIconBuilder(activeTab),
            color: Colors.green,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          tabTitleBuilder(activeTab),
          style: GoogleFonts.adamina(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}