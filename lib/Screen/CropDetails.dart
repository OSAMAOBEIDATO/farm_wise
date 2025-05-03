import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/CropDetailsText/HealthyCrop.dart';
import 'package:farm_wise/CropDetailsText/IrrigationCrop.dart';
import 'package:farm_wise/CropDetailsText/TimeCrop.dart';
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
  String ActiveScreen = 'Time';

  void setActiveScreen(String activeScreen) {
    ActiveScreen = activeScreen;
  }

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
                      buildActionButton(
                          label: 'Time',
                          fontSize: 20,
                          onTap: () {
                            setState(() {
                              setActiveScreen('Time');
                            });
                          }),
                      const SizedBox(height: 12),
                      buildActionButton(
                          label: 'Healthy',
                          fontSize: 20,
                          onTap: () {
                            setState(() {
                              setActiveScreen('Healthy');
                            });
                          }),
                      const SizedBox(height: 12),
                      buildActionButton(
                          label: 'Irrigation',
                          fontSize: 18,
                          onTap: () {
                            setState(() {
                              setActiveScreen('Irrigation');
                            });
                          }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
             Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ActiveScreen,
                style:GoogleFonts.adamina(color: Colors.black,fontSize: 22,fontWeight: FontWeight.w900 )
              ),
            ),
            const SizedBox(height: 10),
            if (ActiveScreen == 'Irrigation')
              IrrigationCrop(
                  irrigationcrop: widget.crop.irrigationGuide,
                  waterRequirement: widget.crop.waterRequirement),
            if (ActiveScreen == 'Healthy')
              Healthycrop(
                  fertilizers: widget.crop.fertilizers,
                  soilType: widget.crop.soilType,
                  sunlight: widget.crop.sunlight,
                  irrigationCrop: widget.crop.irrigationGuide,
                  ),
            if (ActiveScreen == 'Time')
              TimeCrop(
                harvestDate: widget.crop.harvestDate,
                bestPlantingSeason: widget.crop.bestPlantingSeason,
                cropName: widget.crop.name,
                growingTime: widget.crop.growingTime,
                harvestDateNumber: widget.crop.harvestDateNumber,
                plantDate: widget.crop.plantDate,
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
                    : Text('Delete Crop',
                        style: KTextStyle.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
