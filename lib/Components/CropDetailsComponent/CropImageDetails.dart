import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropImageDetails extends StatelessWidget {


  const CropImageDetails({
    super.key,
    required this.cropName,
    this.height = 280,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.boxShadow,
  });

  final String cropName;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: boxShadow ?? _defaultBoxShadow(),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: Image.asset(
          'assets/Image/$cropName.jpg',
          height: height,
          width: width ?? double.infinity,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Image not found',
            style: GoogleFonts.roboto(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> _defaultBoxShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];
  }
}