import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/components/SnakBar.dart';
import 'package:farm_wise/components/buildActionButton.dart';
import 'package:farm_wise/Common/Constant.dart';

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
        MaterialPageRoute(builder: (_) => const MainScreen()),
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
          style: GoogleFonts.adamina(fontSize: 22, color: Colors.black),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Name: ${widget.crop.name}",
                  style: KTextStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  "Planted Date: ${_formatDate(widget.crop.plantDate)}",
                  style: KTextStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  "Harvest Info: ${widget.crop.irrigationGuide ?? "N/A"}",
                  style: KTextStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  "Soil Type: ${widget.crop.soilType ?? "N/A"}",
                  style: KTextStyle,
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isDeleting ? null : _deleteCrop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isDeleting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Delete Crop', style: KTextStyle.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
