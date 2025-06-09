import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_wise/Components/ContentAreaCropDetails.dart';
import 'package:farm_wise/Components/CropDetailsComponent/CropImageDetails.dart';
import 'package:farm_wise/Components/CropDetailsComponent/DeleteButtonDetails.dart';
import 'package:farm_wise/Components/CropDetailsComponent/DeleteConfirmationDialog.dart';
import 'package:farm_wise/Components/CropDetailsComponent/TabButtonDetails.dart';
import 'package:farm_wise/Screen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farm_wise/Models/CropData.dart';
import 'package:farm_wise/components/SnakBar.dart';

enum CropDetailTab { time, healthy, irrigation }

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

class _CropDetailsState extends State<CropDetails>
    with SingleTickerProviderStateMixin {
  bool _isDeleting = false;
  CropDetailTab _activeTab = CropDetailTab.time;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setActiveTab(CropDetailTab tab) {
    if (_activeTab != tab) {
      setState(() {
        _activeTab = tab;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _deleteCrop() async {
    final result = await showDeleteConfirmationDialog(
      context: context,
      cropName: widget.crop.name,
    );
    if (result != true) return;

    setState(() => _isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('crops')
          .doc(widget.crop.cropId)
          .delete();

      if (mounted) {
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: '${widget.crop.name} deleted successfully!',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        CustomSnackBar().ShowSnackBar(
          context: context,
          text: 'Error deleting crop: ${e.toString()}',
        );
      }
    }
  }


  IconData _getTabIcon(CropDetailTab tab) {
    switch (tab) {
      case CropDetailTab.time:
        return Icons.schedule;
      case CropDetailTab.healthy:
        return Icons.eco;
      case CropDetailTab.irrigation:
        return Icons.water_drop;
    }
  }

  String _getTabTitle(CropDetailTab tab) {
    switch (tab) {
      case CropDetailTab.time:
        return 'Planting Info';
      case CropDetailTab.healthy:
        return 'Plant Health';
      case CropDetailTab.irrigation:
        return 'Watering Guide ';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'FarmWise',
          style: GoogleFonts.adamina(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.crop.name,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header gradient
            Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green, Colors.grey[50]!],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Crop image
                  CropImageDetails(
                    cropName: widget.crop.name,
                  ),
                  const SizedBox(height: 24),

                  // Tab buttons
                  Row(
                    children: [
                      TabButtonDetails(
                        label: 'Planting Info',
                        tab: CropDetailTab.time,
                        icon: Icons.schedule,
                        activeTab: _activeTab,
                        onTap: _setActiveTab,
                      ),
                      TabButtonDetails(
                        label: 'Plant Health',
                        tab: CropDetailTab.healthy,
                        icon: Icons.eco,
                        onTap: _setActiveTab ,
                        activeTab: _activeTab,
                      ),
                      TabButtonDetails(
                        label: 'Water',
                        tab: CropDetailTab.irrigation,
                        icon: Icons.water_drop,
                        onTap: _setActiveTab,
                        activeTab: _activeTab,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Content area
                  ContentAreaCropDetails(
                    fadeAnimation: _fadeAnimation,
                    activeTab: _activeTab,
                    crop: widget.crop,
                    tabIconBuilder: _getTabIcon,
                    tabTitleBuilder: _getTabTitle,
                  ),
                  const SizedBox(height: 32),

                  // Delete button
                  DeleteButton(
                    isDeleting: _isDeleting, // bool state managed in parent widget
                    onPressed: () {
                      _deleteCrop();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}