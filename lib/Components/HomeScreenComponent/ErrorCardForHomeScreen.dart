import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorCardForHomeScreen extends StatelessWidget {
  const ErrorCardForHomeScreen({
    super.key,
    required this.title,
    required this.error,
    required this.onRetry,
    this.cardColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
  });
  final String title;
  final String error;
  final VoidCallback onRetry;
  final Color? cardColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context);
    final defaultCardColor = Colors.red.withOpacity(0.1);
    final defaultBorderColor = Colors.red.withOpacity(0.3);
    final defaultIconColor = Colors.red[600];
    final defaultTextColor = Colors.red[700];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor ?? defaultCardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor ?? defaultBorderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: iconColor ?? defaultIconColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor ?? defaultTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: textColor?.withOpacity(0.8) ,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(
              Icons.refresh,
              color: themeColors.colorScheme.onError,
            ),
            label: Text(
              'Retry',
              style: TextStyle(
                color: themeColors.colorScheme.onError,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor ?? defaultIconColor,
            ),
          ),
        ],
      ),
    );
  }
}