import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// StatelessWidget for the dialog content
class DeleteConfirmationDialog extends StatelessWidget {
  final String cropName;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({
    Key? key,
    required this.cropName,
    required this.onCancel,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      title: Text(
        'Delete Crop',
        style: GoogleFonts.adamina(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure you want to delete',
            style: GoogleFonts.roboto(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '"$cropName"?',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'This action cannot be undone.',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Cancel',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Delete',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// Helper function to show the dialog
Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required String cropName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeleteConfirmationDialog(
      cropName: cropName,
      onCancel: () => Navigator.pop(context, false),
      onDelete: () => Navigator.pop(context, true),
    ),
  );
}