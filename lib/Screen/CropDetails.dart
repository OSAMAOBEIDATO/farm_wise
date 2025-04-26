import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:farm_wise/components/buildActionButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/components/SnakBar.dart';

class CropDetails extends StatefulWidget {
  final CropData crop;
  final String userId;

  const CropDetails({
    super.key,
    required this.crop,
    required this.userId,
  });

  @override
  State<CropDetails> createState() => _CropDetailsState();
}

class _CropDetailsState extends State<CropDetails> {
  bool _isDeleting = false;

  Future<void> _deleteCrop() async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Are you sure you want to delete ${widget.crop.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('crops')
          .doc(widget.crop.cropId)
          .delete();

      CustomSnackBar().ShowSnackBar(
        context: context,
        text: '${widget.crop.name} deleted successfully!',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      CustomSnackBar().ShowSnackBar(
        context: context,
        text: 'Error deleting crop: $e',
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FarmWise',
          style: GoogleFonts.adamina(fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/Image/splashScreen.png',
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/Image/splashScreen.png',
                          height: 250,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildActionButton(label: 'Time', fontSize: 20),
                      const SizedBox(height: 12),
                      buildActionButton(label: 'Healthy', fontSize: 20),
                      const SizedBox(height: 12),
                      buildActionButton(label: 'Irrigation', fontSize: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Crop Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Planted: ${_formatDate(widget.crop.plantDate)}'),
            Text('Harvest: ${widget.crop.irrigationGuide}'),
            Text('Type: ${widget.crop.soilType}'),
          ],
        ),
      ),
      bottomSheet: _isDeleting
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : TextButton(
        onPressed: _deleteCrop,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 3),
            Text(
              'Delete Crop',
              style: GoogleFonts.adamina(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}