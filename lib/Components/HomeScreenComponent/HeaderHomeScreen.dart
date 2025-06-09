import 'package:farm_wise/Models/DataForHeader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderForHomeScreen extends StatelessWidget {
  const HeaderForHomeScreen({
    super.key,
    required this.refreshData
  });
  final Function() refreshData;


  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greetingData = DataForHeaderHome(hour);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(greetingData.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetingData.greeting,
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome to FarmWise',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            tooltip: 'Refresh data',
          ),
        ],
      ),
    );
  }

  DataForHeader DataForHeaderHome(int hour) {
    if (hour < 12) {
      return DataForHeader(
        greeting: 'Good Morning!',
        icon: Icons.wb_sunny,
        color: Colors.orange,
      );
    } else if (hour < 17) {
      return DataForHeader(
        greeting: 'Good Afternoon!',
        icon: Icons.wb_sunny_outlined,
        color: Colors.amber,
      );
    } else {
      return DataForHeader(
        greeting: 'Good Evening!',
        icon: Icons.nights_stay,
        color: Colors.indigo,
      );
    }
  }
}

