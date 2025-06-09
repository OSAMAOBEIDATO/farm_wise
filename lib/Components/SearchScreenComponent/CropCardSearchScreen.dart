import 'package:farm_wise/Components/SnakBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropCardSearchScreen extends StatelessWidget {
  final Map<String, dynamic> crop;
  final Set<String> selectedCropIds;
  final List<String> existingCropNames;
  final Function() onTap;

  const CropCardSearchScreen({
    super.key,
    required this.crop,
    required this.selectedCropIds,
    required this.existingCropNames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedCropIds.contains(crop['id']);
    final isAlreadyAdded = existingCropNames.contains(crop['name'].toLowerCase());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: selected
            ? Border.all(color: Colors.green, width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: isAlreadyAdded
            ? () {
          CustomSnackBar().ShowSnackBar(
            context: context,
            text: "${crop['name']} is already in your crops!",
          );
        }
            : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isAlreadyAdded
                      ? Colors.grey.withOpacity(0.3)
                      : (selected ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                  image: DecorationImage(
                    image: AssetImage('assets/Image/${crop['name']}.jpg'),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {},
                    colorFilter: isAlreadyAdded
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : null,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isAlreadyAdded
                        ? Colors.grey.withOpacity(0.3)
                        : (selected ? Colors.green.withOpacity(0.1) : Colors.transparent),
                  ),
                  child: Center(
                    child: selected
                        ? Icon(Icons.check_circle, color: Colors.green[600], size: 24)
                        : (isAlreadyAdded
                        ? Icon(Icons.lock, color: Colors.grey[600], size: 24)
                        : const SizedBox()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop['name'],
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isAlreadyAdded ? Colors.grey[600] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          crop['type'] ?? 'Unknown',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (isAlreadyAdded) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Already Added',
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected && !isAlreadyAdded)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.check, color: Colors.green[600], size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}