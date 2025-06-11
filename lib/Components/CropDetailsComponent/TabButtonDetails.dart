import 'package:farm_wise/Screen/CropDetails.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabButtonDetails extends StatelessWidget {

  const TabButtonDetails({super.key,
    required this.label,
    required this.tab,
    required this.icon,
    required this.activeTab,
    required this.onTap,
  }) ;

  final String label;
  final CropDetailTab tab;
  final IconData icon;
  final CropDetailTab activeTab;
  final Function(CropDetailTab) onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = activeTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isActive ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
            border: isActive
                ? null
                : Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}