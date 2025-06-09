import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyStateForHomeScreen extends StatelessWidget {

  const EmptyStateForHomeScreen({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.agriculture,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.onAction,
    this.actionText,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onAction;
  final String? actionText;


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.green[600])!.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: iconColor ?? Colors.green[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor ?? Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(actionText ?? 'Add First Crop'),
            ),
          ],
        ],
      ),
    );
  }
}