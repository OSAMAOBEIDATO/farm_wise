import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropImageDetails extends StatelessWidget {


  const CropImageDetails({
    super.key,
    required this.cropName,
    this.height = 280,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String cropName;
  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:BorderRadius.circular(20),
        boxShadow:  _defaultBoxShadow(),
      ),
      child: ClipRRect(
        borderRadius:  BorderRadius.circular(20),
        child: Image.asset(
          'assets/Image/$cropName.jpg',
          height: height,
          width: width ?? double.infinity,
          fit: fit,
        ),
      ),
    );
  }



  List<BoxShadow> _defaultBoxShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 10),
      ),
    ];
  }
}